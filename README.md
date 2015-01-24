# NSProgress example

This project shows how to use NSProgress in a Cocoa/AppKit context, where you may have multiple things in progress, and want to coalesce them into a single master progress feedback UI through creating a tree of NSProgress objects.

Features shown:

* Creating parent/child NSProgress objects with an implicit parent established through `[NSProgress becomeCurrentWithPendingUnitCount:]`
* Running code on relevant progress completion in both the children and parents
* Propagating cancellation from children to parents
