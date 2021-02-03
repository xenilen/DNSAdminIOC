# DNSAdminIOC
PowerShell Script that hunts for IOC identified in https://medium.com/techzap/dns-admin-privesc-in-active-directory-ad-windows-ecc7ed5a21a2

---

Other things to look for specified in that article are
- To prevent the attack, audit ACL for write privilege to DNS server object and membership of DNSAdmins group.
- Obvious indicators like DNS service restart and couple of log entries:
- DNS Server Log Event ID 150 for dll load failure and 770 for dll load success
