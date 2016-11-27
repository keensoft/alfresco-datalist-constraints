
alfresco-datalist-constraints
=============================

Use datalists to maintain Alfresco model constraints.

1. Deploy repo and share AMPs to Alfresco 4.2 CE
2. Create a new site named "Administration"
3. Configure site dashboard to include Datalists
4. Create two new datalists from type "Options", one called "Smartphones" and another called "OS"
5. Populate the datalists with some values (01 - Android, 02 - iOS...)
6. Create a new site (with any name)
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