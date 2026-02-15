"""Run every query in queries/ against the Chinook database and save the
results as markdown tables in results/ (one file per .sql file)."""

import re
import sqlite3
from pathlib import Path

import pandas as pd

DB = Path("data/chinook.sqlite")
QUERY_DIR = Path("queries")
RESULTS_DIR = Path("results")


def split_queries(sql_text):
    """Split a .sql file into (question, query) pairs using the '-- Qn:' comments."""
    parts = re.split(r"^-- (Q\d+: .*)$", sql_text, flags=re.MULTILINE)
    # parts looks like [file header, q1 title, q1 sql, q2 title, q2 sql, ...]
    return [(parts[i], parts[i + 1].strip()) for i in range(1, len(parts), 2)]


def main():
    RESULTS_DIR.mkdir(exist_ok=True)
    con = sqlite3.connect(DB)

    for sql_file in sorted(QUERY_DIR.glob("*.sql")):
        lines = [f"# Results: {sql_file.stem}\n"]
        for question, query in split_queries(sql_file.read_text()):
            df = pd.read_sql_query(query, con)
            df = df.astype(object).where(df.notna(), "")  # show empty cells instead of nan
            lines.append(f"## {question}\n")
            lines.append("```sql\n" + query + "\n```\n")
            lines.append(df.to_markdown(index=False) + "\n")

        out = RESULTS_DIR / f"{sql_file.stem}.md"
        out.write_text("\n".join(lines))
        print("wrote", out)

    con.close()


if __name__ == "__main__":
    main()
