The Membership Utility has several core functions:
query a User to see which Permission Set(s), Public Group(s), and Queue(s) he/she belongs to
query a Permission Set, Public Group, or Queue to see a list of its members
It leverages 3 hidden multi picklists on the User record that track Permission Set(s), Public Group(s), and Queue(s)
and a batch that runs nightly to update these fields with any changes in membership.

It is manifested in several ways:
a Visualforce page to query a User to see which Permission Set(s), Public Group(s), and Queue(s) he/she belongs to
3 Visualforce pages, one each to query a Permission Set, Public Group, and Queue to see a list of their respective members
a component on a Salesforce System Case to automatically query the Profile, Permission Sets, Public Groups, and Queues of the Case Contact
reporting on the 3 hidden multi picklists

Version 2 will replace the 3 multi picklists with a Custom Object and Related List that tracks "SObjects",
including Permission Set(s), Public Group(s), and Queue(s). This will actually require a Junction Object since the relationships are many-to-many. It will be linked to the SObjects in Application Inventory.