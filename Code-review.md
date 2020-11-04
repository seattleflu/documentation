Code review is an important part of building quality software.  We review each
other's code in order to:

* Keep tabs on what's changing to build and maintain shared understanding of
  our systems.

* Solicit and incorporate the knowledge and experience of the team to improve
  the code and understanding of the problem being solved.

* Reduce the number of bugs or design flaws that make it into production to
  avoid outsized impacts from only uncovering them later.

Shared understanding is the most important part of code review.  It is nice to
avoid bugs and flaws, but as it is impossible to avoid them entirely, it's
important to focus on work that makes fixing problems _easier_.


## Guidelines

Code review interactions should primarily foster discussion and aim to produce
rough consensus or agreement.  Suggesting changes is ok, but code reviews are
much more than creating a [punch list](https://m-w.com/dictionary/punch+list)
of changes required by a gatekeeper.

Communication is hard, especially via text-only mediums, and constructive
critique doubly so.  Be kind and generous and give people the benefit of the
doubt.  Try to over communicate rather than under communicate.  Video calls can
reduce lots of back and forth on hard-to-discuss topics, but afterwards be sure
to recap what you discussed for the benefit of the rest of the team.

Try to be timely, but realize that sometimes it's worth taking time to get
feedback and do it right.  Talk explicitly about that tradeoff, as it is
different case to case.  It's ok to ping people if PRs aren't getting
attention.

Pay attention to commit structure (how code changes are organized into
individual commits), sequence (what order the commits are in), and messages
(why these changes are being made), as crafting these well can make it much
easier for new team members and our future selves to maintain the codebase.
Historical context for why previous changes were made is invaluable for
understanding when and how you might want to change that code again.  The
commits themselves, not just the changes they make, are part of the review too.

### As an author

* Direct reviewers' attention to any parts you're unsure of or specific topics
  on which you'd like feedback.

* Follow up with reviewer comments to acknowledge them.  This can be as quick
  as a reaction emoji or as open-ended as a discussion about the comment.

* Wait for at least one approval from another team member before merge and
  deploy.  More reviews are always ok!  Use your judgment if you think input
  from more team members would be worthwhile for any reason (for example, the
  scope, scale, intricacy of the changes).

* Close the loop with the reviewer after implementing suggested changes.  Check
  back with the person who suggested the changes and see if your solution
  matches what they expected.  This checks for shared understanding and
  miscommunication.

### As a reviewer

* Be explicit about which of your suggested changes you consider merge blockers
  and which may be deferred, especially if it's possibly unclear.

* Tag yourself as reviewing a PR by self-requesting a review when you start
  digging in.  This lets others know you're reviewing the PR, so they can
  decide to review it as well or spend their time elsewhere.

* Close the loop with the author to check back on changes they've implemented
  at your suggestion.

* If something doesn't make sense, consider if there's a reason or rationale
  you're not thinking of.  Ask.
