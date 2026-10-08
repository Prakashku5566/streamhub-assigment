import { test, expect } from '@playwright/test';

test.describe('A3 API Testing - JSONPlaceholder POST /posts', () => {
  const baseURL = 'https://jsonplaceholder.typicode.com/posts';

  test('should handle excessively long title gracefully', async ({ request }) => {
    const longTitle = "A".repeat(10000);
    const response = await request.post(baseURL, {
      data: {
        title: longTitle,
        body: "Test body",
        userId: 1
      }
    });

    // Documenting actual response behavior without blind assumptions
    // Assessment requirement: server failure nahi hona chahiye (status < 500)
    expect(response.status()).toBeLessThan(500);
    
    // Log the actual status to document real behavior
    console.log(`Long title response status: ${response.status()}`);
  });

  test('should handle unsupported special characters in payload', async ({ request }) => {
    const response = await request.post(baseURL, {
      data: {
        title: "Test 🚀",
        body: "Body with null byte \u0000 and zero-width \u200B",
        userId: 1
      }
    });

    expect(response.status()).toBeLessThan(500);
    console.log(`Special chars response status: ${response.status()}`);
  });

  test('should handle missing userId gracefully', async ({ request }) => {
    const response = await request.post(baseURL, {
      data: {
        title: "Test missing userId",
        body: "Test body"
        // userId omitted
      }
    });

    expect(response.status()).toBeLessThan(500);
    console.log(`Missing userId response status: ${response.status()}`);
    
    // We expect the API to either create it anyway or throw a 400 bad request, 
    // but definitely NOT a 500 Server Error.
    const responseBody = await response.json();
    console.log('Missing userId actual response:', responseBody);
  });
});
