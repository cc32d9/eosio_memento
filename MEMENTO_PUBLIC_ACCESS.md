Public access to Memento database
=================================


Provided by EOS Amsterdam
-------------------------

* Retention periond: 48h
* MariaDB Host: `memento.eu.eosamsterdam.net`
* MariaDB Port: 3350
* User: `memento_ro`
* Password: `memento_ro`
* Databases:
  * `memento_eos`
  * `memento_proton`
  * `memento_telos`
  * `memento_wax` (filtered actions: `farmersworld:claim`, `m.federation:mine`)

Example:

```
mysql --host=memento.eu.eosamsterdam.net --port=3350   --user=memento_ro --password=memento_ro --database=memento_wax
```
  

