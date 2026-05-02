# Market-Monitoring-Agentforce

AI-driven Wealth Management Agent using Salesforce FSC, Agentforce, and Data Cloud.

## Solution Overview
The Market Monitoring Agent is an autonomous AI solution designed for Financial Services. It addresses the challenge Relationship Managers face in reacting quickly to market volatility.

### Key Features
- **Data Cloud Integration:** Real-time market data ingestion and Identity Resolution across client portfolios.
- **Autonomous Monitoring:** Agentforce-powered agent monitors market events and identifies at-risk clients.
- **Intelligent Segmentation:** Calculates "AUM at Risk" and prioritizes high-value client outreach.
- **360-Degree Relationship Brief:** LWC providing RMs with AI-generated strategies and family milestones.
- **Omni-channel Outreach:** Automated Slack alerts for RMs and one-click personalized WhatsApp messages for clients.

## Technical Components
- **Apex:** Custom handlers for segmentation and messaging (`MarketSegmentationEngine`, `WhatsAppOutreachHandler`).
- **Agentforce:** Autonomous topics for reasoning and strategic advisory.
- **Flow:** Automated activity logging and data orchestration.
- **Data Cloud:** Calculated Insights and Data Streams.

## Setup
1. Deploy metadata to Salesforce Org.
2. Configure Named Credentials for Slack and WhatsApp.
3. Activate the Market Monitoring Agent in Agentforce.
