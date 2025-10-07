# Connecting CyVerse to GitHub
The [CyVerse Utils repo](https://github.com/CU-ESIIL/cyverse-utils/tree/main) contains scripts to set up github key pairs for both R and Python (they are also copied in this directory).
Run the appropriate script, then add the key to your Github account ([ssh keys](https://github.com/settings/keys))
Clone the needed directory with the ssh link:
```
git clone <SSH LINK>
```
You may now use basic git commands, e.g.:
```
git add -A
git commit -m "MESSAGE"
git push origin main
```

# Data transfer


## GoCommands
If you ever are unable to move data between an instance and the datastore, host connection to the data store may have been temporarily lost. The host will attempt to auto-reconnect; if for any reason it doesn't or you don't want to wait, you can [use GoCommands](https://learning.cyverse.org/ds/gocommands/#download-gocommands) to move the data, which should be pre-installed on most CyVerse images. 

Additionally, **data transfers of greater than 2GB need to be done via GoCommands.**

General GoCommands usage:

1)
```
./gocmd init
```
2) enter until username and password (to paste in, right click after copying)
3) Upload:
```
./gocmd put /local/path.txt /iplant/home/etc
```

## Streaming data from the CyVerse store
Public cyverse data can be viewed at: [data.cyverse.org/dav/iplant/commons/community_released](https://data.cyverse.org/dav/iplant/commons/community_released)

An overview of the CyVerse WebDAV service is here: [https://cyverse-data-store-guide.readthedocs-hosted.com/en/latest/step5.html](https://cyverse-data-store-guide.readthedocs-hosted.com/en/latest/step5.html)

The overall WebDAV service is here, including the commons AND protected project folders:
[https://data.cyverse.org/dav/](https://data.cyverse.org/dav/)

EarthLab's community released data folder is here: [https://data.cyverse.org/dav/iplant/commons/community_released/earthlab/](https://data.cyverse.org/dav/iplant/commons/community_released/earthlab/)

To stream data from the commons WebDAV service, use URLs with the structure:
```
https://de.cyverse.org/anon-files/iplant/home/shared/earthlab/...
```

To stream data from a protected WebDAV service, use URLs with the structure: 
```
https://data.cyverse.org/dav/iplant/projects/<project>/...
```

For example, in R:
```
z <- readr::read_csv(
  "https://de.cyverse.org/anon-files/iplant/home/shared/earthlab/macrosystems/lens-aop-continental-scaling/data/derived/lfr_grouped_cats.csv"
)
```

## Cloud-to-instance data access

The best and most efficient way to access most data from within your Cyverse instance is via APIs, VSI, or STAC. Examples of such data access can be found throughout the data library. This is the preferred method of data access since it keeps data on the cloud, puts it directly on your instance, and then the data is removed upon instance termination. Note that any data you want to keep must be moved off the instance and to the Cyverse data store prior to instance termination (see below, "Saving data from your instance to the data store").

### Pre-downloaded data on Cyverse data store

Some data can be time consuming or frustrating to access. Or, you or one of your teammates may just be much more comfortable working with data that has effectively been 'downloaded locally'. In an attempt to streamline your projects, the ESIIL and Earth Lab teams have loaded a set of data onto the Cyverse data store, which can be read from your Cyverse instance.

Pre-downloaded data for the Forest Carbon Codefest can be found in the Cyverse data store at [this link.](https://de.cyverse.org/data/ds/iplant/home/shared/earthlab/forest_carbon_codefest?type=folder&resourceId=74dd0094-8d46-11ee-a930-90e2ba675364)

The path directory to this location from within a Cyverse instance is:
```
~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest
```
Note that, while data CAN be read on your instance directly from the data store, it is usually best to move the data to your instance prior to reading and processing the data. Having the data directly on your instance will dramatically improve processing time and performance. (see below, "Moving data from the data store to your instance")

### Moving data from the data store to your instance

Use the terminal command line interface on your instance to move data from the data store to your instance (whether that is pre-downloaded data or data that you have saved to your team folder). The home directory of your instance is:
```
/home/jovyan
```
To do so, open the Terminal from your launcher. Then, use the 'cp' command to copy data from the data store to your instance. Use the flag -r if you are moving an entire directory or directory structure.

The command is in the form:
```
cp -r data-store-location new-location-on-instance
```
For example, the below command will move the entire LCMAP_SR_1985-2021 directory to a new data directory on your instance:
```
cp -r ~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/LCMAP_SR_1985_2021 /home/jovyan/data/
```
### Saving data from your instance to the data store

Any data or outputs that you want to keep, such as newly derived datasets or figures, must be moved off the instance and to the Cyverse data store prior to instance termination. To do so, you will follow the same steps as in "Moving data from the data store to your instance" (see above), but with the directories in the command reversed, e.g.:
```
cp -r /home/jovyan/figures ~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/Team_outputs/Team1/
```