/// <reference types="cypress" />

Cypress.on('uncaught:exception', (err, runnable) => {
  // Return false to prevent Cypress from failing the test
  return false;
});

Cypress.Commands.add('login', (username, password) => {
  cy.visit('http://localhost:9292/account/login')
  cy.get('input[name="username"]').type(username)
  cy.get('input[name="password"]').type(password)
  cy.get('button[type="submit"]').click()
  cy.url().should('include', '/posts/random')
})

describe('Landing Page and Navigation', () => {
  beforeEach(() => {
    cy.visit('http://localhost:9292/')
  })

  it('Verifies navbar links', () => {
    const navbarLinks = {
      'Home': '/',
      'About': '/about',
      'Ads': '/ads'
    }

    // Check if each navbar link goes to the correct location
    Object.entries(navbarLinks).forEach(([linkText, linkHref]) => {
      cy.contains('a', linkText)
        .should('have.attr', 'href', linkHref)
    })
  })

  it('Verifies Join Now button before login', () => {
    cy.get('a[href="/account/signup"]')
      .should('contain', 'Join Now')
      .should('have.attr', 'href', '/account/signup')
  })

  it('Logs in and verifies navbar and button state change', () => {
    cy.login('john', 'secretPassword')

    // After login, verify the updated navbar links
    cy.contains('a', 'Posts').should('have.attr', 'href', '/posts')

    // Visit landing page again
    cy.visit('http://localhost:9292/')

    // Check that the Join Now button has changed to "View Posts"
    cy.get('a[href="/posts/home"]').should('contain', 'View Posts')
  })
})

describe('Post Sorting Tabs', () => {
  beforeEach(() => {
    cy.login('john', 'secretPassword') // Ensure user is logged in
    cy.visit('http://localhost:9292/posts/random') // Start at the random posts page
  })

  it('Checks that clicking on different sort tabs redirects correctly', () => {
    const postTabs = {
      'New': '/posts/new',
      'Hot': '/posts/hot',
      'Controversial': '/posts/controversial',
      'Random': '/posts/random'
    }

    Object.entries(postTabs).forEach(([tabName, tabUrl]) => {
      cy.contains('a', tabName).click()
      cy.url().should('include', tabUrl)
      cy.visit('http://localhost:9292/posts/random') // Return to random after each check
    })
  })

  it('Checks that dropdown selection redirects correctly (Mobile)', () => {
    cy.visit('http://localhost:9292/posts/random') // Reset state

    cy.viewport(375, 667) // iPhone 6/7/8 dimensions (simulate mobile)

    const dropdownSelector = 'select[id="Post Sort Options"]' // Fix for ID with spaces
    const postTabs = {
      'Hot': '/posts/hot',
      'Controversial': '/posts/controversial',
      'Random': '/posts/random'
    }

    Object.entries(postTabs).forEach(([tabName, tabUrl]) => {
      cy.get(dropdownSelector).select(tabUrl)
      cy.url().should('include', tabUrl)
      cy.visit('http://localhost:9292/posts/random') // Reset state
    })
  })
})

describe('Post Interaction', () => {
  beforeEach(() => {
    cy.login('john', 'secretPassword') // Ensure user is logged in
    cy.visit('http://localhost:9292/posts/random') // Start at the random posts page
  })

  it('Upvotes the first post and checks if the count increases', () => {
    cy.login('john', 'secretPassword') // Ensure user is logged in
    cy.visit('http://localhost:9292/posts/random');

    // Select the first post
    cy.get('div.w-full.bg-transparent.shadow-md').first().as('firstPost');

    // Click the comment button to navigate to the post page
    cy.get('@firstPost')
      .find('a[href^="/post/"]')
      .first()
      .click();

    // Ensure the new page loads
    cy.url().should('include', '/post/');

    // Get the initial upvote count
    cy.get('span.text-xs.text-gray-500')
      .eq(1) // Select the second instance
      .invoke('text')
      .then((initialUpvotes) => {
        const initialCount = parseInt(initialUpvotes.trim(), 10) || 0;

        // Click the upvote button
        cy.get('form[action*="/upvote"] button').click();

        // Wait for the upvote to process
        cy.wait(500);

        // Check if the upvote count increased by 1
        cy.get('span.text-xs.text-gray-500')
          .eq(1) // Select the second instance
          .invoke('text')
          .should((newUpvotes) => {
            const newCount = parseInt(newUpvotes.trim(), 10);
            expect(newCount).to.equal(initialCount + 1);
          });
        
        // Remove upvote
        cy.get('form[action*="/upvote"] button').click();


        // Check if the upvote count increased by 1
        cy.get('span.text-xs.text-gray-500')
          .eq(1) // Select the second instance
          .invoke('text')
          .should((newUpvotes) => {
            const newCount = parseInt(newUpvotes.trim(), 10);
            expect(newCount).to.equal(initialCount);
          });
        
      
    });

  })

  it('Adds & Deletes post', () => {
    // Press the + button
    cy.get('[data-modal-target="post-modal"]').click();

    cy.get('input[name="title"][id="title"]') // Selects the input with name="title" and id="title"
    .type('Title'); // Types "Title" into the input field
    cy.get('input[id="channel-input"]') // Selects the input with name="title" and id="title"
    .type('Ruby Enthusiasts'); // Types "Title" into the input field
    cy.get('textarea[name="content"][id="content"]') // Selects the input with name="title" and id="title"
    .type('Test Content'); // Types "Title" into the input field

    cy.contains('button[type="submit"]', 'Post').click();

    cy.url().should('include', '/post/');

    // Step 1: Capture the current URL
    cy.url().then((currentUrl) => {
      // Step 2: Click the button
      cy.get('button.text-red-500').click();

      // Step 3: Wait for the navigation or page reload (if necessary)
      cy.wait(10); // You can adjust the wait time depending on how long it takes to reload the page

      // Step 4: Ensure the page returns a 404 error
      cy.request({
        url: currentUrl, // Use the captured URL
        failOnStatusCode: false, // Prevent Cypress from failing the test if it gets a 404
      }).its('status').should('eq', 500); // Check if the status is 404
    });
  });
});