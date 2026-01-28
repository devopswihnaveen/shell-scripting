#!/bin/bash
#this script simulates a team conversation scenario with variable team member names
TEAM_LEAD="Yash"
DEVELOPER1="Naveen"
DEVELOPER2="Vajid"
QA_ENGINEER="Gowtham"
echo "$TEAM_LEAD: Hi Team, let's discuss our project updates."
sleep 1
echo "$DEVELOPER1: I've completed the API integration and pushed the changes to the repo."
sleep 1
echo "$DEVELOPER2: I've been working on the frontend design and it's almost ready for review."
sleep 1
echo "$QA_ENGINEER: I've started testing the new features and will share the report by end of the day."
sleep 1
echo "$TEAM_LEAD: Great work everyone! Let's ensure we meet our deadlines."
sleep 1
echo "$DEVELOPER1: I'll also start working on the unit tests for the API."
sleep 1
echo "$DEVELOPER2: I'll coordinate with the QA team to ensure smooth testing."
sleep 1
echo "$QA_ENGINEER: I'll focus on regression testing to ensure existing features are unaffected."
sleep 1
echo "$TEAM_LEAD: Perfect! Let's have a quick sync-up tomorrow morning."
sleep 1
echo "All: Sounds good! See you tomorrow."
echo "Team conversation simulation completed." 