const router = require('../routes/listings');

describe('Listings route access regression', () => {
  it('keeps GET /:id before protect middleware (public detail page)', () => {
    const stack = router.stack;

    const listingDetailIndex = stack.findIndex(
      (layer) => layer.route?.path === '/:id' && layer.route?.methods?.get
    );
    const protectIndex = stack.findIndex((layer) => layer.name === 'protect');

    expect(listingDetailIndex).toBeGreaterThan(-1);
    expect(protectIndex).toBeGreaterThan(-1);
    expect(listingDetailIndex).toBeLessThan(protectIndex);
  });
});

