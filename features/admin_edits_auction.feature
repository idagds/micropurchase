Feature: Admin edits auctions in the admins panel
  As an admin
  I should be able to modify existing auctions

  Background:
    Given I am an administrator
    And I sign in

  Scenario: Updating an auction
    Given there is an open auction
    And there is a client account to bill to
    And I visit the auctions admin page

    When I click to edit the auction
    Then I should see the current auction attributes in the form
    And I should be able to edit the existing auction form

    When I click on the "Update" button
    Then I should be on the admin auctions page
    And I expect my auction changes to have been saved
    And I should see the start time I set for the auction
    And I should see the end time I set for the auction

    When I click on the auction's title
    Then I should see new content on the page

  Scenario: Associating an auction with a customer
    Given I am an administrator
    And I sign in
    And there is an open auction
    And there is a customer
    And I visit the auctions admin page

    When I click to edit the auction
    Then I should see a select box with all the customers in the system

    When I select a customer on the form
    And I click on the "Update" button
    Then I expect the customer to have been saved

    When I click to edit the auction
    Then I should see the customer selected for the auction
