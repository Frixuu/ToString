# tostring

Haxe macro for automatically generating `toString` methods.

## How to use

- To generate the method, use this build macro (autobuild also works fine):

  ```haxe
  @:build(tostring.ToString.generate())
  ```

- To exclude a field from being printed out, use meta:
  
  ```haxe
  @:tostring.exclude
  ```

## Example

```haxe
class Animal {
    public var age: Int;
    public var name: Null<String>;
    @:tostring.exclude public var momName: Null<String>;
}

@:build(tostring.ToString.generate())
class Dog extends Animal {
    @:tostring.exclude public var favoriteFood: String;
    public var breed: Breed;
    public var ageInDogYears(get, never): Int;
    public function get_ageInDogYears(): Int {
        return this.age * 7;
    }
}
```

Example output:

```text
Dog { age: 6, name: Rex, breed: GoldenRetriever, ageInDogYears: 42 }
```
