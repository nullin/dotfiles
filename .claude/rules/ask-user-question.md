# AskUserQuestion Validation

When using AskUserQuestion, always check the returned answer content.

If answers come back empty or blank (e.g., "User has answered your questions: ." with no actual selections visible):

1. Do NOT assume or fabricate what the user selected
2. Acknowledge the tool issue to the user
3. Re-ask the questions, or ask the user to provide answers in free text
4. Only proceed once you have confirmed, visible answers

This applies especially during multi-round interviews where several consecutive calls may silently fail.
