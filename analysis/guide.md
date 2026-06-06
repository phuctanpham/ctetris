# Single-line command (PowerShell 7) to fetch all raw data
```
pwsh -NoProfile -ExecutionPolicy Bypass -File ./fetch_all.ps1
```
output dir:

```
raw_data/
│
├── GIT ──────────────────────────────────────────────────────
│   git_commits_list.csv       hash,author,email,date,message
│   git_commits_files.csv  ⭐  + cột status,file  (module mapping)
│   git_diff_stats.csv     ⭐  insertions/deletions per file  (MD proxy)
│   git_merges.csv             merge commits  (MC base)
│   git_branches.csv           branch list + commit count
│   git_shortlog.txt           tổng commits per author
│   git_author_daily.csv       activity theo ngày  (sprint trend)
│
├── SLACK ────────────────────────────────────────────────────
│   slack_users.csv        ⭐  UID → real name  (không cần hardcode)
│   slack_messages.csv     ⭐  toàn bộ messages (paginated, không còn giới hạn 100)
│   slack_replies.csv      ⭐  thread replies đầy đủ  (SM count chính xác)
│   slack_bots.json            bot name lookup
│   slack_files.csv            file đính kèm per message
│   slack_channel.json         channel metadata
│
├── TRELLO ───────────────────────────────────────────────────
│   trello_cards.csv       ⭐  + listName column  (Done/Todo/...)
│   trello_actions.csv     ⭐  audit log: ai move card lúc nào  (MD timeline)
│   trello_lists.csv           tên cột board
│   trello_members.csv         member ID → username
│   trello_checklist_items.csv sub-tasks nếu có
│
└── GITHUB PR (nếu dùng -WithGhPR) ──────────────────────────
    gh_prs.json                full PR metadata + reviews
    gh_pr_files.csv       ⭐  PR → file path  (MC / GC cross-check)
    gh_pr_commits.csv     ⭐  commits trong từng PR  (kiennt branch work)
    gh_contributor_stats.json  weekly activity per author
    gh_issues.json             GitHub Issues
```