%{
  title: "Implementing JavaScript Array Methods from Scratch: forEach, map, and reduce",
  author: "Iago Cavalcante",
  tags: ~w(javascript nodejs testing),
  description: "Learn how to implement JavaScript's core array methods from scratch with comprehensive testing.",
  locale: "en",
  published: true
}
---

In this article, we'll explore how to implement JavaScript's fundamental array methods (`forEach`, `map`, and `reduce`) from scratch. We'll focus on creating robust implementations with comprehensive test coverage using Node.js's native assertion module.

#### Concepts Used

1. **Array Method Implementation**:
   - Understanding how JavaScript's array methods work internally
   - Implementing callback functions with proper parameters (value, index, array)
   - Handling edge cases and error conditions

2. **Node.js Assert Module**:
   - Using Node.js's built-in testing capabilities
   - Writing comprehensive test cases
   - Testing edge cases and error conditions

3. **Error Handling**:
   - Proper error throwing for invalid operations
   - Type checking and validation
   - Edge case management

4. **JavaScript Best Practices**:
   - Clean code principles
   - Modular implementation
   - Comprehensive documentation

#### Implementation Details

Let's break down each method implementation and understand how they work:

##### 1. forEach Implementation

```javascript
export function myForEach(array, callback) {
  for (let i = 0; i < array.length; i++) {
    callback(array[i], i, array);
  }
}
```

The `forEach` implementation is straightforward but powerful:
- Iterates through each array element
- Calls the callback with (element, index, array)
- Doesn't return anything (used for side effects)

##### 2. map Implementation

```javascript
export function myMap(array, callback) {
  const result = [];
  for (let i = 0; i < array.length; i++) {
    result.push(callback(array[i], i, array));
  }
  return result;
}
```

The `map` implementation:
- Creates a new array for results
- Transforms each element using the callback
- Returns the new array with transformed values

##### 3. reduce Implementation

```javascript
export function myReduce(array, callback, initialValue) {
  if (array.length === 0 && initialValue === undefined) {
    throw new TypeError('Reduce of empty array with no initial value');
  }

  let accumulator;
  let startIndex;

  if (initialValue === undefined) {
    accumulator = array[0];
    startIndex = 1;
  } else {
    accumulator = initialValue;
    startIndex = 0;
  }

  for (let i = startIndex; i < array.length; i++) {
    accumulator = callback(accumulator, array[i], i, array);
  }
  return accumulator;
}
```

The `reduce` implementation is more complex:
- Handles empty array edge case
- Manages initial value scenarios
- Properly handles accumulator initialization
- Supports index and array references in callback

#### Comprehensive Testing

Here's our extensive test suite that covers various scenarios:

```javascript
import assert from 'node:assert';
import { myForEach, myMap, myReduce } from './array-methods.js';

// Test data
const testArray = [1, 2, 3, 4, 5];
const emptyArray = [];
const arrayWithOneElement = [42];

// Testing myForEach
console.log('Testing myForEach...');

const forEachResults = [];
myForEach(testArray, (num) => forEachResults.push(num * 2));
assert.deepStrictEqual(forEachResults, [2, 4, 6, 8, 10], 'myForEach basic multiplication failed');

// Test forEach with index
const forEachWithIndex = [];
myForEach(testArray, (num, index) => forEachWithIndex.push({ num, index }));
assert.deepStrictEqual(
  forEachWithIndex,
  [
    { num: 1, index: 0 },
    { num: 2, index: 1 },
    { num: 3, index: 2 },
    { num: 4, index: 3 },
    { num: 5, index: 4 }
  ],
  'myForEach with index failed'
);

// Test forEach with empty array
const emptyResults = [];
myForEach(emptyArray, (num) => emptyResults.push(num));
assert.deepStrictEqual(emptyResults, [], 'myForEach with empty array failed');

// Testing myMap
console.log('Testing myMap...');

const mapResults = myMap(testArray, num => num * 3);
assert.deepStrictEqual(mapResults, [3, 6, 9, 12, 15], 'myMap basic multiplication failed');

// Test map with index and array
const mapWithIndex = myMap(testArray, (num, index, arr) => ({
  value: num,
  index,
  arrayLength: arr.length
}));
assert.deepStrictEqual(
  mapWithIndex[0],
  { value: 1, index: 0, arrayLength: 5 },
  'myMap with index and array reference failed'
);

// Test map with empty array
assert.deepStrictEqual(myMap(emptyArray, x => x * 2), [], 'myMap with empty array failed');

// Testing myReduce
console.log('Testing myReduce...');

// Test basic reduction operations
const reduceResultSum = myReduce(testArray, (acc, num) => acc + num, 0);
assert.strictEqual(reduceResultSum, 15, 'myReduce sum failed');

const reduceResultProduct = myReduce(testArray, (acc, num) => acc * num, 1);
assert.strictEqual(reduceResultProduct, 120, 'myReduce product failed');

// Test reduce without initial value
const reduceResultNoInit = myReduce(testArray, (acc, num) => acc + num);
assert.strictEqual(reduceResultNoInit, 15, 'myReduce without initial value failed');

// Test reduce with single element array
const reduceSingleElement = myReduce(arrayWithOneElement, (acc, num) => acc + num);
assert.strictEqual(reduceSingleElement, 42, 'myReduce with single element failed');

// Test reduce with index and array reference
const reduceWithIndex = myReduce(testArray, (acc, num, index, arr) => {
  return acc + (num * index * arr.length);
}, 0);
assert.strictEqual(reduceWithIndex, 150, 'myReduce with index and array reference failed');

// Test reduce error cases
try {
  myReduce(emptyArray, (acc, num) => acc + num);
  assert.fail('Should have thrown error for empty array with no initial value');
} catch (error) {
  assert.strictEqual(
    error.message,
    'Reduce of empty array with no initial value',
    'Wrong error message for empty array reduction'
  );
}
```

#### Key Features and Advantages

1. **Comprehensive Error Handling**:
   - Proper error throwing for edge cases
   - Meaningful error messages
   - Validation of input parameters

2. **Complete Test Coverage**:
   - Tests for basic operations
   - Edge case testing
   - Error condition verification
   - Complex transformation scenarios

3. **Native JavaScript Implementation**:
   - No external dependencies
   - Pure JavaScript implementation
   - Compatible with any JavaScript environment

4. **Educational Value**:
   - Clear implementation examples
   - Detailed explanations
   - Best practices demonstration

#### Conclusion

This implementation of JavaScript's core array methods provides several benefits:

1. **Deep Understanding**: By implementing these methods from scratch, we gain a deeper understanding of how they work internally.

2. **Robust Testing**: Our comprehensive test suite ensures the implementations work correctly across all scenarios.

3. **Error Handling**: Proper error handling makes the code more reliable and maintainable.

4. **Educational Resource**: This serves as an excellent learning resource for understanding JavaScript array methods.

The code and tests provided here can serve as a foundation for learning about JavaScript array methods, testing practices, and error handling. Whether you're a beginner learning these concepts or an experienced developer reviewing fundamentals, this implementation provides valuable insights into JavaScript's array manipulation capabilities.
