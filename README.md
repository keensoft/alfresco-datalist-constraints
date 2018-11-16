
alfresco-datalist-constraints
=============================

*Compatible with Alfresco CE 4.2.c, 4.2.f, 5.0.d, 5.1.g (aka 201605) & 5.2.g (aka 201707)*

**Lastest release** available at [3.2.2](https://github.com/keensoft/alfresco-datalist-constraints/releases/tag/3.2.2)

Using datalists to maintain Alfresco model constraints.

1. Deploy repo and share AMPs to Alfresco
2. Create a new site selecting Site Preset **Dictionary**
3. Configure site dashboard to include *Datalists*
4. Create two new datalists from type "Options", one called "Smartphones" and another called "OS"
5. Populate the datalists with some values (01 - Android, 02 - iOS...)
6. Create a new site
7. Upload a new document
8. Add "Sample" aspect to document
9. On "Option lists" section you should see two new fields ("option" and "another option") with combos showing the data populated on step 5

![alt tag](https://cloud.githubusercontent.com/assets/1818300/2766867/b0fcbb8c-ca32-11e3-83f4-f2ff76690683.png)

![alt tag](https://cloud.githubusercontent.com/assets/1818300/2766889/fd96af8e-ca32-11e3-9dbe-04af7007c113.png)

## Version 2.1.0

Only repo artifact is versioned as 2.1.0, available at [datalist-model-repo.amp](https://github.com/keensoft/alfresco-datalist-constraints/releases/download/2.1.0/datalist-model-repo.amp)

Requires an additional property at `alfresco-global.properties`

```bash
datalist.show.ordered=true
```

If **true** values are showed ordered by value in combos, if **false** values are showed as they were introduced in combos.

## Version 2.1.1

Both artifacts are versioned as 2.1.1

Support for multiple values control

```xml
<field id="ks:option">
    <control template="/org/alfresco/components/form/controls/datalistSelectone-multiple.ftl">
        <control-param name="itemType">Option</control-param>
    </control>                    
</field>
```

*Based in Doña Ana County [multivalue form control](https://github.com/donaanacounty/multivalueFormControl)*

## Version 2.1.2

Both artifacts are versioned as 2.1.2

Fixed deployment of web resources in the file-mapping.properties 

## Version 3.0.0

AMP artifacts ready-to-deploy available at [3.1.0](https://github.com/keensoft/alfresco-datalist-constraints/releases/tag/3.1.0)

It can be defined the same DataList ID to be applied locally inside a Site, overriding global `Dictionary` datalist values. When using for advanced search, new `search` parameter has been added for FTL control in order to mix all values from local sites and `Dictionary` sites.

** Sample scenario **

Datalist definitions

```
Dictionary Site > Datalist "Options" > Values = 1,2
Sample 1 Site   > Datalist "Options" > Values = 3,4
Sample 2 Site   > No datalist defined
```

Values provided by combos 

```
Outside from a Site  > Values = 1,2
From Advanced Search > Values = 1,2,3,4
From Sample 1 Site   > Values = 3,4
From Sample 2 Site   > Values = 1,2
```

>> Sample custom model and Share form definition are being provided at folder `datalist-sample`

## Version 3.1.0

Added controls for default value and parent selection

## Version 3.2.0

AMP artifacts ready-to-deploy available at [3.2.0](https://github.com/keensoft/alfresco-datalist-constraints/releases/tag/3.2.0)

Keywords `[ADD]` and `[REPLACE]` have been added to define the behaviour of a list inside a Site:

* `[ADD]` merges values from global Dictionary list and Site list
* `[REPLACE]` includes only values from Site list

This keyword has to be included in any place at `Description` field when declaring the list inside a Site.

** Sample scenario **

Datalist definitions

```
Dictionary Site > Datalist "Options" > Values = 1,2
Sample 1 Site   > Datalist "Options" (including [ADD] in description) > Values = 3,4
Sample 2 Site   > Datalist "Options" (including [REPLACE] in description) > Values = 3,4
Sample 3 Site   > No datalist defined
```

Values provided by combos 

```
Outside from a Site  > Values = 1,2
From Advanced Search > Values = 1,2,3,4
From Sample 1 Site   > Values = 1,2,3,4
From Sample 2 Site   > Values = 3,4
From Sample 3 Site   > Values = 1,2
```

# Sample script to create lists and values from command line

```bash
#!/bin/sh

# Alfresco server hostname
hostname=localhost
# Basic auth, admin/admin by default
authorization="Authorization: Basic YWRtaW46YWRtaW4="

# Lists names
lists=("lista1" "lista2" "lista3")

# Values by list name
lista1=("code1a,value1a" "code1b,value1b")
lista2=("code2a,value2a" "code2b,value2b")
lista3=("code3,value3")

for listName in "${lists[@]}"; do

	listNodeRef=$(curl --silent -X POST \
	  http://"${hostname}"/alfresco/s/api/type/dl%3AdataList/formprocessor \
	  -H "${authorization}" \
	  -H 'content-type: multipart/form-data;' \
	  -F alf_destination=workspace://SpacesStore/582ca69b-4a38-42ac-bb7b-d215929a2e17 \
	  -F prop_cm_title=$listName \
	  -F prop_dl_dataListItemType=dlm:optionList \
	  | grep "persistedObject" | cut -c"25-" | rev | cut -c"3-" | rev)

	echo "Created list $listName ($listNodeRef)"

	values="${listName}[@]"
	for value in "${!values}"; do

		code=$(echo "${value}" | cut -d "," -f 1)
		value=$(echo "${value}" | cut -d "," -f 2)

		itemNodeRef=$(curl --silent -X POST \
		  http://"${hostname}"/alfresco/s/api/type/dlm%3AoptionList/formprocessor \
	      -H "${authorization}" \
		  -H 'content-type: multipart/form-data;' \
		  -F alf_destination=$listNodeRef \
		  -F prop_dlm_code=${code} \
		  -F prop_dlm_value=${value} \
		  | grep "persistedObject" | cut -c"25-" | rev | cut -c"3-" | rev)
		  
	done

done
```