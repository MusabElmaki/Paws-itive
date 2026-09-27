'use strict';

function money(value) {
  if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0 || value > 100000) {
    throw new Error('Enter an amount between RM0.01 and RM100,000.');
  }
  const cents = Math.round(value * 100);
  if (cents < 1 || Math.abs(cents / 100 - value) > 0.000001) throw new Error('Use at most two decimal places.');
  return cents;
}
function discountFor(points) { return points >= 600 ? 0.15 : points >= 300 ? 0.10 : points >= 100 ? 0.05 : 0; }
function transition(from, to) {
  return ({reported: ['underReview', 'beingAssisted'], underReview: ['beingAssisted'], beingAssisted: ['resolved'], resolved: []}[from] || []).includes(to);
}
function periodKeys(now = new Date()) {
  const d = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  d.setUTCDate(d.getUTCDate() - (d.getUTCDay() + 6) % 7);
  return {week: d.toISOString().slice(0, 10), month: now.toISOString().slice(0, 7)};
}
function coordinates(latitude, longitude) {
  if (latitude == null && longitude == null) return {latitude: null, longitude: null};
  if (!Number.isFinite(latitude) || !Number.isFinite(longitude) || Math.abs(latitude) > 90 || Math.abs(longitude) > 180) throw new Error('Choose a valid map location.');
  return {latitude, longitude};
}
module.exports = {money, discountFor, transition, periodKeys, coordinates};
