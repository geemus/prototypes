APIED
=====

apied is an attempt to provide a unified definition of an API that produces documentation as well as client and server code.

Content-Type
------------

* Anything that has a body (request or response) should be JSON and reflect the associated resource.
* Headers should be used for any metadata (ie pagination).

Errors
------

* Errors should use an appropriate status code to represent what went wrong.
* The body of an error should be json of `{ 'errors' => [one_or_more_errors] }`.
* Should return errors on non-json and for any unknown json keys or malformed json values.

Versioning
----------

* Versions may have major, minor and patch versions and should be updated with each deploy.
* Users may limit their choice via a header (default is latest) and will get as loose as the specify.
* 1.2.3 will only match this version, 1.2 will match any patch version, 1 will match any minor and/or patch version.
* Patch versions should represent non-breaking changes (most common).
* Minor versions indicate the addition of functionality or the deprecation (but not removal) of functionality.
* Major versions may indicate addition of functionality and are required for modification or removal of functionality.
* Deprecated features should continue to work for some extended time before ultimate removal.

Routes
------

```
DELETE  /objects/:id  # delete object by id
GET     /objects      # listing of objects
GET     /objects/:id  # object data by id
HEAD    /objects/:id  # object headers by id
OPTIONS /objects      # Allows header with %w{GET OPTIONS POST} and json formatted documentation
OPTIONS /objects/:id  # Allows header with %w{DELETE GET HEAD OPTIONS PATCH PUT} and json formatted documentation
PATCH   /objects/:id  # object update by id
POST    /objects      # object creation without id (returns representation including generated id)
PUT     /objects/:id  # object replacement by id

? Batch operations
  takes a hash (where keys are ids and values are the bodies for that id)
  in the case of delete it simply takes an array
  returns a hash, with key ids and body values for what each request would do individually
  naively this would simply call the singular action many times serially, but might allow for optimized implementations
DELETE /objects       # delete an array of objects by id
PATCH  /objects       # patch several objects, with hash data of id keys and body values
POST   /objects       # create one or more objects without id, takes either a hash for one object or an array for many
PUT    /objects       # replace several objects, with hash data of id keys and body values
```
