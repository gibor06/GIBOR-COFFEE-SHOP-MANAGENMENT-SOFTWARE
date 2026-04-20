# Agent Contracts

## 1. project war commander
Own:
- requirement analysis
- assumptions
- backlog
- milestone mapping
- dependency graph
- integration plan
- final delivery package

Must output:
- task id
- owner
- supporting role
- expected output
- priority
- milestone
- dependency
- completion criteria

## 2. ui-auth-integrator lead
Own:
- screen list
- navigation flow
- login
- authorization by role
- menu behavior
- integration order
- ui consistency
- build and integration checklist

Must output:
- views and viewmodels to create
- login flow
- role matrix
- navigation map
- integration checklist
- ui test checklist

## 3. data-core-inventory architect
Own:
- database design
- category and supplier masters
- product module
- search
- purchase invoice
- inventory update rules
- validation and test data

Must output:
- table list with keys and relationships
- repository/service map
- CRUD rules
- search rules
- purchase and stock logic
- data validation checklist
- data test cases

## 4. sales-analytics-report finisher
Own:
- sales invoice
- stock deduction on sales
- analytics queries
- simple report
- advanced report
- project report outline
- screenshots and demo flow
- final submission checklist

Must output:
- sales flow
- stock deduction rules
- analytics rules and data sources
- report scope
- documentation outline
- demo checklist
- submission checklist

## Handoff contract
Every internal handoff should use this exact structure:
- from agent:
- to agent:
- task id:
- objective:
- input:
- output handed off:
- related files or modules:
- acceptance criteria:
- remaining blocker:

## Priority order for blockers
1. build failure
2. login or authorization failure
3. database write failure
4. inventory inconsistency
5. purchase or sales flow failure
6. analytics mismatch
7. report formatting issues
8. cosmetic ui issues
