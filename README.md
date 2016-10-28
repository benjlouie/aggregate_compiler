# aggregate_compiler

This is an aggregate repository - as such, it is a repository with submodules that are repositories themselves. This is a bit tricky to work with at first, but if you follow these steps (read: use the scripts) you should be fine (at least for the git stuff).

Steps:

1) Pull down the aggregate repository

2) run gitUpdateCheckoutMaster

	- This initializes the git submodules and switches all of the projects to master

After the repositories are initialized, you can start coding in them. You can commit code, revert stuff, and do all of that right from those repositories as they won't affect anything else in any other repository.

There are a couple other scripts

1) gitUpdate
	This pulls from the remote repository for each submodule. Usefull if you're in a weird state and you're just like 'ALL I WANT IS TO UPDATE!!!! :'(

2) gitUpdateCheckoutBranch

	This goes into each repository and checks out a branch you specify on the command line, like this

		./gitUpdateCheckoutBranch testBranch

	If you are working on a single problem, but you're working in 2 or more repositories, this is helpful because, as long as you name the branches the same, you can check them all out at once.

MORE Git scripts to come as we need them!!

REMEMBER Every commit to our repositories needs a pull request. Please respect that!!
