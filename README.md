# ARC 7 slurm el7 test-site
This repository holds the arc.conf and slurm configuration files for the ARC SLURM test-site with frontend: arctestcluster-hackathon-slurm-el7-ce1.cern-test.uiocloud.no

This is a mini-cluster with 1 ARC-CE SLURM frontend, and with 1 compute node. 

The purpose of this site is to have a persistent ARC SLURM site where one can do experimentation and testing. 

Via GitLab (or the GitHub mirror) site you can via merge requests (pull requests) change the arc.conf, slurm.conf or slurmnodes.conf files on the cluster. 
You can also install a new ARC plugin that can be used in the authgroup or mapping blocks in arc.conf. 

The cluster is set up with a web-service for you to be able to view the arc.conf, the ARC logs, and check the ARC status. This can be useful if you want to check if the changes you attempted to the configuration or auth/mapping plugin was successful. 

If you have access to GitLab you can also get information on the success or failure of your changes via labels added by the system to the original MR.  


See details below  on how to. 

**Table of contents**

[[_TOC_]] 


# Interacting with the web services

## Read ARC conf file as currently  present on site
View arc.conf via curl or web-broser with: [http://arctestcluster-hackathon-slurm-el7-ce1.cern-test.uiocloud.no/arcconf](http://arctestcluster-hackathon-slurm-el7-ce1.cern-test.uiocloud.no/arcconf)

## Read ARC log files
Browse ARC log files via curl or web-browser with: [http://arctestcluster-hackathon-slurm-el7-ce1.cern-test.uiocloud.no/arclogs](http://arctestcluster-hackathon-slurm-el7-ce1.cern-test.uiocloud.no/arclogs)


## Check ARC state
View ARC state via curl or web-browser with: [http://arctestcluster-hackathon-slurm-el7-ce1.cern-test.uiocloud.no/arcstatus](http://arctestcluster-hackathon-slurm-el7-ce1.cern-test.uiocloud.no/arcstatus)


## How to use the Gitlab/GitHub webhooks to change configuration files and install plugins
Change the arc.conf or slurm configuration files (slurm.conf slurmdbd.conf or slurmnodes.conf), or install a new plugin, in the following way 
(assuming you know the git cli)

- Clone the repo
- Checkout a new branch 
- Do the changes to the configuration files, push branch upstream
- Create a merge request following the url link from the push
- Add one label per configuration file you changed. Pick from the pre-defined labels.  
  - conf:arc 
  - conf:slurm
  - conf:slurmdbd
  - conf:slurmnodes
  - arc:install_plugin
- Once the merge request is merged, the webhook will try to replace the configuration files.
- You will see the result as new labels in the merge request
- You can check the status of ARC following the url requests mentioned above. 


### Concrete example
Depending on if you are accessing this page from GitLab (A) or the Github mirror site (B), you do:
A) Gitlab:

```
git clone https://source.coderefinery.org/nordugrid/arctestsite-hackathon-slurm-el7-arc7.git
``` 

B) GitHub mirror site:

```
git clone https://github.com/nordugrid/arctestsite-hackathon-slurm-el7-arc7.git
``` 

Then for either option, use normal git procedures to commit changes and create a merge request (MR, GitLab) or pull request (PR, GitHub)

Example:

```
cd arctestsite-hackathon-slurm-el7-arc7
git checkout -b mynewtestbranch
```

Do changes in e.g. arc.conf, then:

```
git add arc.conf
git commit -m "I did some changes in arc.conf for testing the procedure"
git push -u origin mynewtestbranch
``` 

- Then follow the instructions from the push command on how to create a merge request with the url provided. 
- Add appropriate labels (see instructions above).In this example the correct would be `conf:arc`
- Merge the merge-request, or ask someone with access to merge for you if you are not allowed.
- Only once the merge-request is merged, will the configuration files be updated on the test cluster. 



## Replacing arc.conf or slurm configuration

Whenever the arc.conf or the slurm config files in the main branch changes via a merge request, the new arc.conf/slurm config files are pulled onto arctestcluster-slurm-ce1, and replaced with the old ones. ARC/slurm is restarted with the new configuration. 

You need to label your merge-requests according to what files you have changed. Only the files corresponding to the labels chosen will be updated upon the merge. 

Once the merge request has been accepted, you will see whether the replacement went ok or not by checking the labels on the original MR. If something went wrong, only Maiken can typically check the webhook to see what is wrong. 
The replacement will fail for instance if the arc.conf validation failed e.g. if the arc.conf has some wrong entries or if something actually went wrong with the webhook service itself. 




## Install an auth plugin or mapping plugin
To install a new auth plugin on the server, two steps are needed
1. Create the auth plugin script in ./arcplugins folder in git
2. Update the arc.conf file to use the auth plugin 


### 1. Install plugin
Assuming you have cloned the repo, and created your dev-branch

1. Create the plugin script in the arcplugins folder
2. Commit and push
3. Create MR/PR
4. Label the MR/PR with arc:install_plugin

### 2. Configure ARC to use the plugin

1. Create a dev-branch
2. Update arc.conf to use the plugin:
  - How to configure ARC for authentication via plugin: https://www.nordugrid.org/arc/arc6/admins/reference.html#plugin
  - How to configure ARC for mapping via plugin: https://www.nordugrid.org/arc/arc6/admins/reference.html#map-with-plugin
3. Commit and push
4. Create MR/PR
5. Label the MR/PR with conf:arc



## What do the labels added by the system mean 

- fetch-conf:<conftype>:failure
  - If fetching the configuration from gitlab failed, then this label is added to the merge request by the webhook.
  - Nothing else will be tried so replacing the configuration has failed. 
- update-conf-<conftype>:success 
  - If configuration (e.g. slurm.conf, slurmdbd.conf, arc.conf etc) was successfully replaced
- reconfig:success
  -  After replacing the config the service is restarted or reconfigured, typically with ´´scontrol reconfig´´ or ´´arcctl service restart -a ´´ - if this succeeds, i.e. config is valid, then success
- reconfig:failure: 
  - reconfig failed, so something is wrong with the configuration you tried updating
- reverted-config-<conftype>:success
  - If reconfig:failure then the system tries to restore to the original configuration. And restart the service. This succeeded if label is present.
- cluster:fix-manually 
  - If reconfig:failure and reverting to original config failed, then this label is added. Cluster needs manually restoring/checking. 




