const {test} = require('node:test');
const assert = require('node:assert/strict');
const {money, discountFor, transition, periodKeys, coordinates} = require('../policy');
test('money rejects NaN, infinity, negatives, oversized and fractional-cent amounts', () => {
  for (const n of [NaN, Infinity, -1, 0, 0.001, 100001, '20']) assert.throws(() => money(n));
  assert.equal(money(19.99), 1999);
  assert.equal(money(0.01), 1);
});
test('discount is derived from trusted points and capped', () => {
  assert.equal(discountFor(0), 0); assert.equal(discountFor(100), .05);
  assert.equal(discountFor(300), .10); assert.equal(discountFor(100000), .15);
});
test('case transitions reject repeated awards and reopening', () => {
  assert.equal(transition('reported', 'resolved'), false);
  assert.equal(transition('beingAssisted', 'resolved'), true);
  assert.equal(transition('resolved', 'beingAssisted'), false);
  assert.equal(transition('beingAssisted', 'beingAssisted'), false);
});
test('UTC periods change at calendar boundaries, including year crossover', () => {
  assert.deepEqual(periodKeys(new Date('2026-01-01T12:00:00Z')), {week:'2025-12-29', month:'2026-01'});
});
test('unknown locations stay unknown; invalid coordinates are rejected', () => {
  assert.deepEqual(coordinates(null, null), {latitude:null, longitude:null});
  assert.throws(() => coordinates(91, 0)); assert.throws(() => coordinates(null, 100));
  assert.deepEqual(coordinates(1.56, 103.63), {latitude:1.56, longitude:103.63});
});
