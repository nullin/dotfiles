---
name: interview
description: Interviews the user in depth about a plan using probing, non-obvious questions. Use for "/interview", "challenge my assumptions", or deep exploration of a plan before implementation.
allowed-tools:
  - AskUserQuestion
  - Read
---

# Plan Interview Skill

This skill helps you thoroughly explore and stress-test plans through in-depth questioning.

## When to Use This Skill

Use this skill when:
- A user has outlined a plan and wants it challenged
- You need to uncover hidden assumptions or risks
- A plan needs to be fleshed out before implementation
- The user wants to think through edge cases and tradeoffs

## Process

1. **Review Context**
   - Read the entire conversation to understand the plan being discussed
   - Identify the core goals, constraints, and proposed approach

2. **Interview In-Depth**
   - Use the AskUserQuestion tool to probe the plan
   - Ask about anything relevant: technical implementation, UI/UX, concerns, tradeoffs, edge cases, assumptions, risks, dependencies
   - Make questions non-obvious - probe deeper into things they might not have considered
   - Challenge assumptions directly
   - Ask about the hard parts

3. **Keep going until the risks are surfaced**
   - Continue while questions are still uncovering hidden assumptions, risks, or scope edges
   - Push one level past the first answer when it reveals an assumption
   - Stop once the material unknowns are on the table - don't pad with low-value questions

4. **Summarize**
   - Once complete, re-iterate the full plan incorporating everything discussed
   - Highlight key decisions made and risks identified

## Question Categories

Consider probing these areas:
- **Technical**: Architecture, scalability, performance, security
- **UX**: User flows, error states, edge cases, accessibility
- **Dependencies**: External services, libraries, team coordination
- **Risks**: What could go wrong? What's the fallback?
- **Assumptions**: What are we taking for granted?
- **Scope**: What's in/out? Where are the boundaries?
- **Maintenance**: How will this evolve? Who maintains it?

## Key Principles

- **Probe past the first answer** - the first answer is usually the rehearsed one
- **Challenge assumptions** - Question things that seem "obvious"
- **Explore failure modes** - What happens when things go wrong?
- **Stay curious** - Follow interesting threads deeper
