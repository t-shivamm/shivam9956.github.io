Commands 

	· sudo mv ~/Downloads/terraform10 /usr/local/bin/
	· # Change ownership of /usr/local/bin/ to your user sudo chown $(whoami) /usr/local/bin/ 
	· mv old_filename new_filename
	· mv original_file.txt new_file.txt 
	· mvoriginal_file.txt /path/to/new_directory/new_file.txt
	· unzip tfplan_3xeio.zip

Git Commmands
	· git status
	· git add <file(s)>
	· git commit -m "Your commit message"
	· git rm <file(s)>
	· Create a new branch -- git branch <branch_name>
	· Switch to a branch -- git checkout <branch_name>
	· Create a new branch and switch to new branch --git checkout -b <new_branch_name>
	· Delete a branch git branch -D feat
	
	GIT Rebase
	-- If you are working on your feature branch and you have to rebase your branch first you have to switch to master branch and git pull for latest changes.
	-- After that again switch to your feature branch and execute git rebase master
	It will get your feature branch latest codes.
	- After that again switch to master branch and execute git rebase feature/branch

	Rebasing a feature branch from the master branch involves incorporating the latest changes from the master branch into the feature branch. This process allows you to update your feature branch with the most recent changes made to the master branch, ensuring that your feature branch is up to date and compatible with the latest codebase.

To rebase a feature branch from the master branch, you typically follow these steps:

1. Checkout the feature branch: `git checkout feature-branch`

2. Fetch the latest changes from the remote repository: `git fetch origin`

3. Ensure that your local master branch is up to date: `git checkout master` followed by `git pull origin master`

4. Switch back to the feature branch: `git checkout feature-branch`

5. Rebase the feature branch onto the updated master branch: `git rebase master`

During the rebase process, Git will apply each commit from the feature branch on top of the updated master branch. If there are any conflicts between the changes in the feature branch and the updated master branch, Git will pause the rebase process and prompt you to resolve the conflicts manually.

After resolving any conflicts, you can continue the rebase process by running `git rebase --continue`. If you encounter any issues or want to abort the rebase, you can use `git rebase --abort` to revert back to the original state of the feature branch.

Once the rebase is complete, your feature branch will contain the latest changes from the master branch. It is important to note that rebasing rewrites the commit history of the feature branch, so it should only be done on branches that have not been shared with others or pushed to a remote repository.

Push your newly created Local Branch to Remote branch
 -- git add .  --add all files 
Git commit -m " mesaage"
Git push --set-upstream origin feat/DEVOP-2176


Terraform Commands 

TFENV_TERRAFORM_VERSION=1.1.0 aws-sso exec --profile 328645840678:TE-Full-Admin pwsh ./runtfv2.ps1 -envname test -tfcomm terraform -operation intapply -projects 'asg/ppbo'


TFENV_TERRAFORM_VERSION=1.1.0 aws-sso exec --profile 328645840678:TE-Full-Admin usr/local/bin/pwsh ./runtfv2.ps1 -envname test -tfcomm terraform -operation plan -projects 'asg/ppbo'

aws-sso exec --profile 328645840678:TE-Full-Admin pwsh ./runtfv2.ps1 -envname test -tfcomm terraform1.1.0 -operation plan -projects 'asg/ppbo'


TFENV_TERRAFORM_VERSION=1.1.0 aws-sso exec --profile 328645840678:TE-Full-Admin pwsh ./runtfv2.ps1 -envname test -tfcomm terraform -operation plan -projects 'asg/ppbo'

TFENV_TERRAFORM_VERSION=1.1.0 aws-sso exec --profile 328645840678:TE-Full-Admin pwsh ./runtfv2.ps1 -envname inte -tfcomm terraform -operation plan -projects 'asg/ppbo'

aws-sso exec --profile 242396308979:AdministratorAccess

terraform % TFENV_TERRAFORM_VERSION=1.1.0 aws-sso exec --profile 328645840678:TE-Full-Admin pwsh ./runtfv2.ps1 -envname inte -tfcomm terraform -operation intapply -projects 'asg/loungegateway'


UAT 

TFENV_TERRAFORM_VERSION=1.1.0 aws-sso exec --profile 179356486124:TE-Full-Admin pwsh ./runtfv2.ps1 -envname uat -tfcomm terraform -operation plan -projects 'asg/ppbo,asg/rule,asg/account'



	1. Download the terraform version which you want.
	2. Open terminal and become root user by sudo su and provideing the password
	3. Paste this command  -->>  mv /Users/shivamtiwari/Downloads/terraform /usr/local/bin
	4. Run terraform version command ---> terraform --version to check
7sa40 



Git Manual Merge (its need to be done before creating pull request to master branch)

1 -- Checkout to master branch from feature branch 
  git checkout master/main
2 -- Now pull the latest changes from remote repository
like commits made by other user because currently your local master doesn't have updated code 
  git pull 
3 -- Now again checkout to feature branch and do the merge (master will be merged to feature branch )
  git checkout feature/prac-1
  git merge 

4 Now you can merge your code to master branch without any conflict


-- Git Auto merge 
git tries to merge the master branch automatically but it will be only successfull when the 
changes are in diffrent lines of code but you
will run into merge conflicts when same line of code which you change are already changed by other 
after you cut your feature from master branch -----(GIT AUTO MERGE WILL FAIL)