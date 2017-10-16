
alfresco-datalist-constraints
=============================

*Compatible with Alfresco CE 4.2.c, 4.2.f, 5.0.d, 5.1.g (aka 201605) & 5.2.g (aka 201707)*

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

AMP artifacts ready-to-deploy available at [3.0.0](https://github.com/keensoft/alfresco-datalist-constraints/releases/tag/3.0.0)

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
