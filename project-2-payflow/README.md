# Project 2 — PayFlow Mobile Payment Feature

**Domain:** Fintech / Mobile | **Duration:** 8 weeks | **Status:** Complete

**Tools:** Jira · Confluence · draw.io · Excel

---

## The Problem

PayFlow had 180,000 active users but a 34% checkout abandonment rate. Every payment redirected users to an external browser — they had to re-enter card details, wait 6 to 8 seconds for processing, and manually navigate back to the app. On mobile, that journey failed constantly.

The business wanted a native in-app payment feature using Stripe. My job was to define exactly what it needed to do before engineering started.

## What I Did

I was the only BA on the feature. I ran the requirements workshops, wrote the FRD covering every payment scenario (not just the happy path — success, failure, timeout, refund, partial payment, 3DS authentication, duplicate prevention, retry logic), specified the Stripe API integration in detail, built the full Jira backlog, and produced the UAT test plan.

The most significant single decision I made was identifying that using Stripe Elements removes PayFlow from PCI-DSS scope entirely. That saved an estimated 6 months of compliance overhead. It came out of reading the Stripe documentation properly — not from a workshop.

I also did a structured wireframe review in Figma and found 6 requirement gaps the UX team hadn't captured. Three were P1 issues that would have caused launch problems.

## Key Numbers

| Metric | Before | Target |
|---|---|---|
| Checkout abandonment rate | 34% | ≤ 20% |
| Average payment time | 8 seconds | < 2 seconds |
| Payment-related support tickets | 28% of all tickets | < 10% |
| Annual revenue lost to abandonment | ~£2.1M | Recover ~£620K |

## What I Produced

- Functional Requirements Document covering 10 payment scenarios
- Stripe API integration requirements (endpoints, error codes, webhooks, retry logic)
- Jira backlog: 3 Epics, 12 Stories, 28 Subtasks — acceptance criteria on every story
- Requirements Traceability Matrix (BR to FR to UAT, 100% coverage)
- UAT Test Plan: 15 scenarios, entry/exit criteria, sign-off process
- BPMN process maps: AS-IS browser redirect flow and TO-BE native payment flow

## Full Case Study

[View on Notion →](https://rattle-dogwood-96b.notion.site/Portfolio-Shweta-Goyal-Technical-BA-3679d574c24c80369bb2e15ae5a862a6)
