# AdminHub - Coding Tools for School Computers 🎓

**Make coding tools work on Guest accounts - it's that simple!**

## What is AdminHub? 🤔

Imagine you're a teacher and your students need to use Python, Git, or other coding tools on school computers. But there's a problem: they have to log in as "Guest" users, and Guest accounts delete everything when they log out!

AdminHub solves this by:
- Installing coding tools once (by the admin)
- Making them automatically available to every Guest user
- No setup needed by students - it just works!

## For Teachers 👩‍🏫👨‍🏫

### What your students get:
- **Python** - For programming lessons
- **Git** - For saving and sharing code
- **Node.js & npm** - For web development
- **Other tools** - wget, jq for advanced projects

### How it helps you:
- ✅ No more wasted class time installing software
- ✅ Students can start coding immediately
- ✅ Works perfectly with Guest accounts
- ✅ No technical knowledge needed from students

## Super Simple Installation 🚀

### What you need:
1. A Mac with administrator access
2. [Homebrew](https://brew.sh) installed (ask IT if unsure)
3. Guest account enabled on the Mac

### Install in 3 steps:

1. **Download AdminHub**
   ```
   Open Terminal and type:
   git clone https://github.com/luka-loehr/AdminHub.git
   cd AdminHub
   ```

2. **Run the installer**
   ```
   Type:
   sudo ./setup.sh
   
   (You'll need to enter your admin password)
   ```

3. **Say "yes" when asked**
   ```
   When it asks "Should I install the missing tools now?"
   Type: y
   ```

That's it! The installation will take about 5 minutes.

## How to Check It's Working ✅

After installation, run this simple test:
```
./test.sh
```

You should see green checkmarks (✓) for everything.

## For Students 👨‍🎓👩‍🎓

Just log in as Guest - Terminal will open automatically with all tools ready!

Try these commands:
- `python3` - Start Python
- `git --version` - Check Git
- `npm --version` - Check npm

## Troubleshooting for Teachers 🛠️

### "Terminal doesn't open for Guest users"
Run this command as admin:
```
./adminhub-cli.sh repair
```

### "I want to see what's happening"
Check the system status:
```
./adminhub-cli.sh status
```
This shows if everything is working correctly.

### "Something seems broken"
View recent errors:
```
./adminhub-cli.sh logs error
```

### "Status shows warnings when using sudo"
This is normal! When you run:
```
sudo ./adminhub-cli.sh permissions check
```
You might see "DEGRADED" for some components. This is a false alarm - the system works fine. Always check without sudo for accurate status:
```
./adminhub-cli.sh status
```

### "I need to uninstall it"
```
sudo ./uninstall.sh
```

## Advanced Features (for IT admins) 🔧

AdminHub has many advanced features that IT administrators might find useful:
- Health monitoring
- Detailed logging
- Configuration management
- Command-line interface

To see all available commands:
```
./adminhub-cli.sh --help
```

## Common Questions ❓

**Q: Do students need to do anything?**
A: No! They just log in as Guest and start coding.

**Q: Will this slow down the computer?**
A: No, tools only activate when Guest users log in.

**Q: Can I add more tools?**
A: Yes, contact your IT admin to customize the tool list.

**Q: Is this secure?**
A: Yes, Guest users can only use the tools, not modify them.

**Q: What if a student breaks something?**
A: They can't! Guest accounts reset on logout, and the tools are protected.

## Need Help? 🆘

- Check if it's working: `./test.sh`
- See system status: `./adminhub-cli.sh status`
- Quick fix: `./adminhub-cli.sh repair`

## About 📚

Created by Luka Löhr for Lessing-Gymnasium Karlsruhe to make coding education easier.

**License:** MIT (free to use and modify)

---

*Making coding accessible for every student, one Guest account at a time!* 🚀