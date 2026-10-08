import { Page } from '@playwright/test';

export class LoanDashboardPage {
  constructor(private page: Page) {}

  loanAmount = this.page.getByTestId("loan-amount");
  interestRate = this.page.getByTestId("interest-rate");
  loanTenure = this.page.getByTestId("loan-tenure");
  calculateButton = this.page.getByTestId("calculate-button");
  emiResult = this.page.getByTestId("emi-result");
  pieChart = this.page.getByTestId("pie-chart");

  async calculateLoan(
    amount: number,
    rate: number,
    tenure: number
  ) {
    await this.loanAmount.fill(String(amount));
    await this.interestRate.fill(String(rate));
    await this.loanTenure.fill(String(tenure));

    await this.calculateButton.click();
  }
}
