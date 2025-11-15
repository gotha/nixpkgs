# Git Operations Rules

This rule defines how Augment should handle Git operations in this repository.

## Core Principle: Never Commit Automatically

**CRITICAL**: Augment must NEVER perform Git commits, pushes, or other destructive Git operations automatically without explicit user permission.

## Prohibited Operations Without Permission

The following Git operations are PROHIBITED unless the user explicitly requests them:

### 1. **Committing Changes**
- `git commit` (any variant)
- `git commit -m "message"`
- `git commit -am "message"`
- `git commit --amend`

### 2. **Pushing Changes**
- `git push`
- `git push origin <branch>`
- `git push --force`
- `git push --force-with-lease`

### 3. **Branch Operations**
- `git merge`
- `git rebase`
- `git cherry-pick`
- `git reset --hard`
- `git branch -D <branch>` (deleting branches)

### 4. **Remote Operations**
- `git pull` (can modify working directory)
- `git fetch` with destructive flags
- `git remote add/remove/set-url`

### 5. **Destructive Operations**
- `git reset --hard`
- `git clean -fd`
- `git checkout -- .` (discarding changes)
- `git stash drop`

## Allowed Operations (Read-Only)

These Git operations are safe and allowed without permission:

### 1. **Status and Information**
- `git status`
- `git log`
- `git show`
- `git diff`
- `git branch` (listing branches)
- `git remote -v`

### 2. **Safe Navigation**
- `git checkout <branch>` (switching branches, but ask if there are uncommitted changes)
- `git branch <new-branch>` (creating new branches)

### 3. **Safe Inspection**
- `git blame`
- `git ls-files`
- `git rev-parse`
- `git describe`

## Required User Permission Process

When a Git operation requires user permission:

1. **Explain the operation**: Clearly describe what Git command will be executed and its effects
2. **Show the impact**: Display what files will be affected, what changes will be committed, etc.
3. **Ask explicitly**: Use clear language like "Do you want me to commit these changes?" or "Should I push to the remote repository?"
4. **Wait for confirmation**: Do not proceed until the user explicitly confirms

### Example Permission Request Format

```
I need to commit the following changes:
- Modified: pkgs/new-package/default.nix
- Added: .augment/rules/new-rule.md

The commit message would be: "Add new package and update rules"

Do you want me to proceed with this commit? (yes/no)
```

## Safe Workflow Recommendations

### 1. **Making Changes**
- Make file modifications as requested
- Use `git status` and `git diff` to show changes
- Suggest commit messages but don't commit
- Ask user if they want to commit

### 2. **Preparing Commits**
- Use `git add` to stage files (this is safe)
- Show staged changes with `git diff --staged`
- Suggest commit message
- Ask for permission to commit

### 3. **Branch Management**
- Create new branches as needed for features
- Switch to appropriate branches
- Never merge or rebase without permission

## Error Handling

If Augment accidentally attempts a prohibited Git operation:

1. **Stop immediately**: Cancel the operation if possible
2. **Apologize**: Acknowledge the mistake
3. **Explain**: Describe what was attempted and why it was wrong
4. **Ask for guidance**: Let the user decide how to proceed

## Integration with Development Workflow

### 1. **Package Development**
When adding new packages:
- Make all necessary file changes
- Show `git status` to display modifications
- Suggest staging files with `git add`
- Propose commit message
- Ask: "Should I commit these changes?"

### 2. **Rule Updates**
When updating rules or documentation:
- Make the changes
- Show the diff
- Ask for commit permission

### 3. **Testing and Validation**
- Run tests and validation scripts
- Show results
- If changes are needed, make them but don't commit
- Always ask before committing fixes

## Emergency Exceptions

The ONLY exception to these rules is if:
1. The user explicitly says "commit automatically" or similar
2. The user provides a specific commit message and says to use it
3. The user is clearly expecting automatic commits in the context

Even then, confirm the operation before proceeding.

## Summary

- **Default behavior**: Never commit, push, or perform destructive Git operations
- **Always ask**: Get explicit permission for any Git operation that modifies history or remote state
- **Be transparent**: Show what will be done before doing it
- **Err on the side of caution**: If unsure, ask the user

This ensures the user maintains full control over their Git repository and prevents accidental commits or pushes that could disrupt their workflow or collaboration with others.

