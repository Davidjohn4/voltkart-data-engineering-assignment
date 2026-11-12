# voltkart-data-engineering-assignment
Assignmet Pratice

# Voltkart SQL Assignment

SQL Server data engineering assignment covering:

- SQL querying
- CTEs
- Window functions
- Incremental MERGE
- CDC processing
- Query optimization
- Gaps and islands / customer loyalty streaks

## Query Optimization

Question 10 was optimized by:

1. Replacing YEAR(order_date) with a date range.
2. Removing the correlated subquery.
3. Adding indexes to support filtering and joins.

Execution plan and STATISTICS IO screenshots are available
in the screenshots folder.
