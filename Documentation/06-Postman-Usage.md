## Postman Collection Usage

The backend includes a ready-to-use Postman collection and environment for testing and exploring the API.

### 1. Files

Located in the `book_backend` directory:

- `CampusHub_Pro.postman_collection.json`
- `CampusHub_Pro.postman_environment.json`

### 2. Import into Postman

1. Open Postman.
2. Click **Import**.
3. Select `CampusHub_Pro.postman_collection.json` and import it as a new collection.
4. Import `CampusHub_Pro.postman_environment.json` as an environment.

### 3. Configure Environment

After importing the environment:

1. Open the environment in Postman.
2. Update variables such as:
   - `base_url` – for example `http://localhost:5000/api`.
   - Any auth tokens or IDs once you have them.
3. Save changes.

### 4. Using the Collection

- Expand the CampusHub Pro collection.
- Start with **Auth** requests:
  - Register a test user.
  - Log in to obtain tokens.
- Use the returned token as needed in headers (the collection may already be configured to set this for you via test scripts).
- Test listings, chat, reviews, reports, and admin endpoints as needed.

You can use this collection as a reference for how the Flutter app talks to the backend, or adapt it into your own API documentation tooling.

