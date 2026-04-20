---
name: dotnet-course-project-agents
description: 'multi-agent orchestration for end-to-end .net course projects such as cafe management, retail sales, or inventory systems. use when the user wants one workflow that automatically breaks the project into four coordinated roles: project commander, ui/auth integrator, data/core inventory architect, and sales/analytics/report finisher. trigger for requests to scope a project, split work, design database and modules, define milestones, generate implementation checklists, prepare reports, or drive a .net project from rough requirements to demo and submission.'
---

# Dotnet Course Project Agents

## Overview
Coordinate four internal roles to turn a short request into an actionable delivery package for a .net course project. Default domain is a cafe or retail sales system when the user does not specify a domain. Match the user's language.

## Core workflow
Follow this sequence every time.

1. **Project commander** analyzes the request, infers missing assumptions, sets milestones, and creates the integrated backlog.
2. **UI/auth integrator** defines screens, navigation, login, authorization, integration order, and final build checks.
3. **Data/core inventory architect** defines the database, CRUD modules, search, import flow, inventory rules, and validation.
4. **Sales/analytics/report finisher** defines sales, revenue analytics, reports, documentation, demo flow, and submission materials.
5. **Project commander** resolves dependencies, merges all outputs, and produces the final delivery package.

Do not stop at generic advice. Produce concrete deliverables that can be implemented immediately.

## Internal roles and responsibilities
Load [references/agent-contracts.md](references/agent-contracts.md) and use the role boundaries and handoff contract there.

## Default assumptions
Unless the user overrides them, assume:
- desktop stack: .net wpf with mvvm
- database: sql server
- default domain: cafe management or retail sales
- baseline modules: category, supplier, product, search, login/authorization, purchase invoice, sales invoice, revenue statistics, simple report, advanced report, project report
- delivery milestones: week 4, week 7, week 12, week 13, week 14

If the user already provides a stack, domain, or constraints, prefer the user's version.

## What to produce
Always try to produce as many of these as the request needs:
- project summary and technical assumptions
- backlog with task ids, owners, dependencies, priorities, and milestone mapping
- database design with tables, columns, keys, relationships, and sample validation rules
- UI plan with screens, navigation, login, and role-based access behavior
- business flows for purchase, sales, inventory, search, analytics, and reporting
- implementation map listing the classes, repositories, services, viewmodels, and views that should exist
- integration order, test plan, demo plan, and submission checklist
- documentation outline and team work process description

Use the output template in [references/output-template.md](references/output-template.md).

## Decision rules
- If the request is short, infer sensible defaults and continue.
- If the request asks for a full project, generate the integrated package, not just a plan fragment.
- If the request asks for code or SQL, keep the four-role structure but let the most relevant role generate the technical content.
- If the request is about one broken feature, still let the commander assign one primary role and supporting roles.
- If constraints conflict, prioritize: runnable system, correct data, demo readiness, submission readiness.

## Required quality bar
Ensure the final answer is specific enough that a student team can start implementing immediately.

Always include:
- clear ownership for all major tasks
- dependency order between modules
- validation expectations for data entry
- testing checkpoints for login, CRUD, purchase, sales, statistics, and reports
- a final package checklist for source code, database, report, screenshots, demo data, and submission artifacts

## Milestone discipline
Map work to these checkpoints whenever the project is course-based:
- **week 4**: task allocation and team work table
- **week 7**: interface, processing layer, and database model
- **week 12**: core business features
- **week 13**: advanced features and system completion
- **week 14**: report, software package, and submission bundle

## Response style inside the skill
- Speak as if the four roles are genuinely operating.
- Keep sections tightly organized and implementation-focused.
- Use tables only when they materially improve clarity.
- Prefer explicit task lists, handoff notes, and checklists over essays.
- Match the user's language.
