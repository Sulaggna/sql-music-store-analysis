"""A few charts for the README, made from the same SQL queries."""

import sqlite3
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd

DB = Path("data/chinook.sqlite")
OUT = Path("images")
BLUE, ORANGE, GREY = "#2a78d6", "#eb6834", "#898781"

plt.rcParams.update({
    "font.size": 10,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "axes.titleweight": "bold",
    "axes.titlesize": 12,
    "axes.titlelocation": "left",
    "figure.dpi": 150,
})


def query(con, sql):
    return pd.read_sql_query(sql, con)


def genre_chart(con):
    df = query(con, """
        SELECT g.Name AS genre, SUM(il.UnitPrice * il.Quantity) AS revenue
        FROM InvoiceLine il
        JOIN Track t ON t.TrackId = il.TrackId
        JOIN Genre g ON g.GenreId = t.GenreId
        GROUP BY g.Name
        ORDER BY revenue DESC
    """)
    top = df.head(8).copy()
    other = pd.DataFrame({"genre": ["Other genres"], "revenue": [df["revenue"].iloc[8:].sum()]})
    top = pd.concat([top, other], ignore_index=True)
    share = top["revenue"] / df["revenue"].sum()

    fig, ax = plt.subplots(figsize=(7, 4))
    colors = [BLUE] + [GREY] * (len(top) - 1)
    ax.barh(top["genre"][::-1], top["revenue"][::-1], color=colors[::-1])
    for i, (rev, pct) in enumerate(zip(top["revenue"][::-1], share[::-1])):
        ax.text(rev + 5, i, f"${rev:,.0f} ({pct:.0%})", va="center", fontsize=9)
    ax.set_title("Rock brings in about a third of all revenue")
    ax.set_xlabel("Revenue ($)")
    ax.set_xlim(0, top["revenue"].max() * 1.25)
    fig.tight_layout()
    fig.savefig(OUT / "revenue_by_genre.png")
    plt.close(fig)


def country_chart(con):
    df = query(con, """
        SELECT BillingCountry AS country, SUM(Total) AS revenue, COUNT(DISTINCT CustomerId) AS customers
        FROM Invoice
        GROUP BY BillingCountry
        ORDER BY revenue DESC
        LIMIT 10
    """)
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.barh(df["country"][::-1], df["revenue"][::-1], color=BLUE)
    for i, (rev, n) in enumerate(zip(df["revenue"][::-1], df["customers"][::-1])):
        label = "customer" if n == 1 else "customers"
        ax.text(rev + 5, i, f"${rev:,.0f}  ({n} {label})", va="center", fontsize=9)
    ax.set_title("USA and Canada make up over a third of revenue")
    ax.set_xlabel("Revenue ($)")
    ax.set_xlim(0, df["revenue"].max() * 1.35)
    fig.tight_layout()
    fig.savefig(OUT / "revenue_by_country.png")
    plt.close(fig)


def yearly_chart(con):
    df = query(con, """
        SELECT strftime('%Y', InvoiceDate) AS year, SUM(Total) AS revenue
        FROM Invoice
        GROUP BY year
        ORDER BY year
    """)
    fig, ax = plt.subplots(figsize=(7, 3.5))
    ax.bar(df["year"], df["revenue"], color=BLUE, width=0.6)
    for x, y in zip(df["year"], df["revenue"]):
        ax.text(x, y + 8, f"${y:,.0f}", ha="center", fontsize=9)
    ax.set_title("Revenue has been flat at around $450-480 a year")
    ax.set_ylabel("Revenue ($)")
    ax.set_ylim(0, df["revenue"].max() * 1.15)
    fig.tight_layout()
    fig.savefig(OUT / "revenue_by_year.png")
    plt.close(fig)


def agent_chart(con):
    df = query(con, """
        SELECT e.FirstName || ' ' || e.LastName AS agent,
               COUNT(DISTINCT c.CustomerId) AS customers,
               SUM(i.Total) AS revenue
        FROM Employee e
        JOIN Customer c ON c.SupportRepId = e.EmployeeId
        JOIN Invoice i ON i.CustomerId = c.CustomerId
        GROUP BY e.EmployeeId
        ORDER BY revenue DESC
    """)
    fig, ax = plt.subplots(figsize=(7, 3))
    ax.barh(df["agent"][::-1], df["revenue"][::-1], color=[GREY, GREY, BLUE])
    for i, (rev, n) in enumerate(zip(df["revenue"][::-1], df["customers"][::-1])):
        ax.text(rev + 5, i, f"${rev:,.0f} from {n} customers", va="center", fontsize=9)
    ax.set_title("Agent revenue mostly follows how many customers they have")
    ax.set_xlabel("Revenue from the agent's customers ($)")
    ax.set_xlim(0, df["revenue"].max() * 1.35)
    fig.tight_layout()
    fig.savefig(OUT / "revenue_by_agent.png", bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    con = sqlite3.connect(DB)
    genre_chart(con)
    country_chart(con)
    yearly_chart(con)
    agent_chart(con)
    con.close()
    print("charts saved to", OUT)
