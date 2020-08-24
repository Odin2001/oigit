Welcome to OIGIT Object Control
===============================

Installation
------------
Download and install GIT for windows
When prompted ensure that the CRLF question is answered "as is"
This will ensure that Carriage Returns and Linefeeds are unaltered by GIT.
trying to guess what the line separator is and stop downstream issues with source, object and standing data.

Decide if you are resetting your development environment to live.
You may have upgrades in flight and may wish to reset your dev environment to match live.
This allows changes to be re-imported into dev into relevant branches so that the inflight development can begin to be tracked.
If you are doing this copy the dev environment somewhere safe as you will need it for reference and copying changes into branches.

Install the RDK extract using run rdkinstall "path to OIGIT.rdk" into dev/new dev OpenInsight (OI).
This will copy the source and objects for the oigit program suite into OI.

Now that oigit is installed OpenInsight can now be copied to individual users PC's.
This is absolutely necessary as from this point all users will be making individual changes that must be isolated
from each other. 


Copying from the "OpenInsight Folder"
The bridge between the command line and OI is oigit.vbs. In here are variable for database, user and password.
It is configured to use d=SYSPROG, u=SYSPROG, p=<null>. Configure this for your system
Each user must copy the contents of this folder to their local OI development environment. Config is supplied to be able to 
to export the OIGIT suite to a repository. There is also an example configuration with an explanation of all the settings
in the oigit.example.config folder.

The oigit.ini is the default config entry point. This points at sub-config within subfolders


Copying from the "user folder"
find your user folder using echo %USERPROFILE%
copy the contents to that folder, it's usually c:\users\<username>
In the bin folder the file oigit is the entrypoint from BASH to OI and needs configuration to match the local system.
Alter these 3 lines to match your system configuration. oidir and rundir are included as I've seen systems where the OI installation 
has been split. They will almost certainly be the same folder. The temp folder contains a temporary file for the output from OIGIT. 
oidir="/c/revsoft/OInsight"
rundir="/c/revsoft/OInsight"
tempdir="/c/temp"

.gitconfig is a global git configuration file. If you are using multiple git repositories where some of these settings are incompatible 
please move them to the local .gitconfig file.
The [USER] section requires completing per user for name and email address.
The diff tool is defaulted to kdiff3 whereas the merge tool is p4merge. p4merge is not "known" by git so it requires configuration to
ensure it's correct.


Copying from the "git repos folder"
Create a repository for your software by using git Bash. Bash is a full command line for which the scripts oigit and oigitmergetool
were written. It is possible to use alternatives such as CMD or Powershell but these 2 scrpts will require rewriting. Additionally the git hooks
supplied assume the use of Bash and it's unix like capabilties.
Make a folder for your repository, ie. c:\repositories\oigit
Load Bash and go to c:\repositories\oigit using cd /c/repositories\oigit
Notice that paths are Unix like paths in Bash and the c: drive is a folder off of the system root.
Create your git repository by typing git init
This will create the hidden folder .git. 
(Note: to create a file in explorer that starts . you have to have trailing . so creating .config needs entering as .config.)

Copy the files into the repository folder, this included the post-checkout hook which maintains a dos file for the current branch
which is used to synchronise the branch that OI and git think you are on.


Usage
=====
oigit (fromoi|tooi|export) [-t] [-ini=ini path] [-cs=control section]

oigit fromoi
------------
Command to copy all items that are different on OI from what is stored in the repository. OIGIT retrieves all objects included in the configuration from 
within OI and compares them to the equivalent item in the repository. 
Before this happens a comparison is done between the branch stored within the repository 
and the active branch which git is checked out to. If the branches don't match the operation will stop. This is to stop branch polution where the contents of OI 
is stored to an incorrect branch which saves needless unpicking of commits either by resetting the branch or reverse commits.
All items, including compiled object code, that are different are copied from OI over the repository version
If an item exists in the repository but not in OI it will (optionally) be deleted from the repository. Care should be taken when preventing the disposal of orphaned objects.

Note : When a checkout is performed within git the OI branch will not be set to the new active branch. Performing a "oigit tooi" will reset OI so that a subsequent 
"oigit fromoi" will not fail


oigit togit
-----------
Command to copy all items that are different in the git repository from what is stored in OI. OIGIT retrieves all objects in the repository before checking that 
they are included in the configuration before comparing them to the equivalent object in OI.
The branch isn't compared at this point but is written as the active branch so that the branch agrees with a susequent "oigit fromoi" operation.
To prevent losses of objects on OI anything overwritten is copied as a backup as specified in the history section of the configuration. Only the specified object classes are 
saved while the number of backups maintained and the way the objects are stored is also in the configuration.
If an item exists in OI but not in the repository it will (optionally) be deleted from OI. Care should be taken when preventing the disposal of orphaned objects.

oigit export
------------
The export function outputs entities given in the list stored in merge/diffs.txt. The list is the product of a git diff between 2 branches and using the 
--name-status option. The exported files are placed into the folder setup in the configuration using the DRIVE and FOLDER settings within the EXPORT
section, the default path is C:\TEMP\UPGRADES\ . The CLASSES setting is used to control which type of object is output to the export folder.

testmode
--------
testmode (-t) is used to simulate an fromoi or tooi operation. When testmode is invoked nothing is updated but what would have happened is reported back to the 
console

specify ini
-----------
add -ini=ini path to the oigit command line to change the default behavior of looking in the oigit.ini file for the configuration. Overriding the ini
file just means that the initial configuration is read from that file instead of the default. Note: the path doesn't support spaces

specify control section
--------------------
The -CS=control section option overrides the behaviour of the CONTROL_SECTION setting in the CONTROL section in the oigit.ini file. The value supplied is substituted
and that is the section used as the basis for all other settings.

git mergetool
-------------
The mergetool is used in the event of git having a merge conflict. Ordinarily git will attempt to handle a conflict by creating a hybrid source file with a best guess version 
of the two branches, usually with both sets of changes marked. As the git configuration sets all items in the repository as binary git knows not to try and create these hybrid
versions but the downside is that management of a conflict is left to the user. To solve this issue git provides mergetool hooks in the configuration so in the event of a conflict
simply type 'git mergetool' and the merge tool will prepare 3 versions of the objects conflicted within the branch. The 3 versions are labelled as yours, theirs and base.
Yours is the version from your branch, theirs is the version from the branch which you are merging and the base is the version from the latest commit from which both branches share.
It is important to note the proper operation of git merges is to always merge the main development branch into your feature branch. This prevents a complicated merge conflict from polluting 
the development branch without first being resolved in the less important feature branch. This maintains that merging the feature branch back into the main development branch will be
capable of being a fast-forward (git terminology for copying the commit reference from one branch pointer to another). It is recommended to use the --no-ff option when merging back as 
this creates a new commit and allows graphical representation of merges to be easier to follow.

manually start merge window
---------------------------
After the mergetool has been used there will be three versions of every conflicted object which have to be handled by choosing or editing one of the versions. To this end and
OI window OIGIT_MERGECONFLICT has been provided. Due to the fact that the XREV.DLL interface doesn't have access to OI's presentation manager
it is not possible to start OI windows this way so the developer will need to start OI into normal development mode.
First start by executing an oigit tooi. This will prepare OI with the branch you are merging into.
Next start OI and execute the merge conflict window using 'EXEC OIGIT_MERGECONFLICT'. From here select the object in the diff list and either 
choose one of the three buttons or click the Show Diffs button. 
The Show Diffs button opens a 3 way merge window as configured in the oigit config. Some merge diff programs allow editing of a final
version of the code as well as presenting the 3 versions. When editing is complete copy the source into the correct OI editor and
recompile
The 3 version buttons copy that version from the git merge folder into OI and overwrite what is already there, for objects like windows 
the developer will need to hand apply changes these buttons allow quickly switching between the versions. Use can be made of copy
and paste.
It is worth noting that object code and compiled windows should be recreated from source rather than trying to manage versions
unless there is an overriding reason to do so.
When all conflicts have been resolved exit OI and perform a 'oigit fromoi' so that the changes are ready to commit to the conflict resolved branch.
