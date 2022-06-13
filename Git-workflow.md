# Git workflow
---

The standard git workflow we utilize is focused on maintaining a clean commit history for the benefit of outside observers, PR reviewers, and our future selves.

The general steps for working on a new feature branch are as follows (commands covered in more detail below):


### Setup
Before using this workflow, perform the following setup steps:

Block specific git commands:
https://github.com/seattleflu/documentation/blob/master/Macbook-setup.md#block-specific-git-commands

Install git-secrets:
https://github.com/seattleflu/documentation/blob/master/Macbook-setup.md#install-git-secrets


### Pre-PR:
1. Checkout and pull latest main/master branch
2. Create a new feature branch off of main/master
3. Commit code changes at multiple points in development, with each commit representing a relatively discrete change that can be reviewed (and ideally, tested) independently. The commit history and associated comments should "tell a story" of the code changes, but omit details that are not relevant to the final version (e.g. bug fixes, typos).
4. Update `.gitignore(s)` to account for any files that are being added/removed from tracking.
5. Rebase feature branch to incorporate changes to master branch and/or to rework commit history on current branch
6. Run automated tests locally (pytest, mypy, etc.)
7. Check difference against remote branch before pushing
8. Push code changes to Github
9. Review feature branch commit history on Github
10. Open PR when branch is ready for review

### Post-PR review:
11. Review feedback and make changes to code as needed
12. Rebase and squash code changes into appropriate commits to result in a clean history
13. (force*) Push changes to Github, request additional review if needed.
14. Merge and deploy (after PR approval)

_* Note about force pushing: As a general rule, we don't force push to master/main branch, as this can cause issues for other developers working on different branches based off of main/master._

_Force pushing to feature branches where you're the primary or only developer is generally fine. If there are other branches based on yours or multiple developers, its best practice to discuss before doing so._

## Steps 1, 2 - Create a new feature branch
```
git checkout master
git pull
git checkout -b my-new-feature-branch
```

## Steps 3, 4 - Write code and commit changes
(Note: Prior to running `git status`, manually update `.gitignore` files to add/remove files from tracking. Many of our repos include `.gitignore` files that function as allowlists as opposed to the standard denylist behavior)
```
git status
git add [new or updated file]
git commit
```

Commit comments generally should be written using these guidelines (https://cbea.ms/git-commit/).

## Step 5 - Rebase to maintain clean history
Interactive rebasing is a useful way to maitain a clean commit history. During an interactive rebase, commits can be merged, dropped, squashed, or fixedup; and comments added and edited.
```
git checkout master
git pull
git checkout my-new-feature-branch
git rebase -i master
```


## Step 6 - Run automated tests (see each repo's README for available tests)
```
# id3c and id3c-customizations
pipenv run pytest -v
./dev/mypy

# backoffice
./dev/shellcheck
```


## Step 7 - Check code diffences against remote branches
Prior to pushing to Github, review entire diff to confirm that only the expected changes exist between local and remote branches.
```
git diff origin/my-new-feature-branch
git diff origin/master
```


## Step 8, 9, 10 - Push changes to Github, review, and open Pull Request
```
git push [-f] origin my-new-feature-branch
```
Review commits and files changed through Github UI as an additional check prior to opening a pull request.
(i.e. https://github.com/seattleflu/[repo-name]/compare/[my-new-feature-branch])

To assist the reviewer(s) it is often helpful to provide commands that can be used to test the new or updated code in the PR comments.


## Step 11 - Post-PR code changes and rebasing

Make code changes and commit each individually so they may be squashed with previous commits as appropropriate. Commit comments can be used to keep track of where each new commit should go during rebasing.
```
git add [some-filename]
git commit -m 'squash with xyz'
```


## Step 12 - Rebase with master
```
git checkout master
git pull
git checkout my-new-feature-branch
git rebase -i master
```
Squash and reorder commits as needed, updating comments to reflect any changes.


## Step 13 - Push revised branch to Github
```
git push -f origin my-new-feature-branch
```

## Step 14 - Merge and deploy
There should be no merge conflicts after steps 12 and 13, so merging into master can be
done through Github UI on the PR page. Click `Merge pull request` and then delete the
feature branch.

Alternatively, the following commands will accomplish the same:

Merge into master branch
```
git checkout master
git pull
git merge --no-ff my-new-feature-branch
```

Review diff prior to pushing to Github
```
git status
git diff origin/master
git push origin master
```

Delete the remote branch after PR is closed
```
git push origin --delete my-new-feature-branch
```


Perform repo-specific deployment steps documented here:
https://github.com/seattleflu/documentation/blob/master/Deploying.md

After deploying, revisit the now closed PR on Github and add a comment "Deployed".
