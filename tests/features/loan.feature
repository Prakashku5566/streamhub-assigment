Feature: Loan EMI Calculation

  Scenario: Calculate EMI for home loan
    Given I open the loan dashboard
    When I enter loan amount "2500000"
    And I enter interest rate "10"
    And I enter tenure "10"
    And I calculate the EMI
    Then the displayed EMI should match my calculated EMI
    And the payment chart should be visible
    And the chart values should be greater than zero

  Scenario: Calculate EMI for second loan scenario
    Given I open the loan dashboard
    When I enter loan amount "5000000"
    And I enter interest rate "7.5"
    And I enter tenure "15"
    And I calculate the EMI
    Then the displayed EMI should match my calculated EMI
    And the payment chart should be visible
    And the chart values should be greater than zero
