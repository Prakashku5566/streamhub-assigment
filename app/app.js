document.addEventListener('DOMContentLoaded', () => {
    const loanAmountInput = document.getElementById('loan-amount');
    const interestRateInput = document.getElementById('interest-rate');
    const tenureInput = document.getElementById('tenure');
    const calculateBtn = document.getElementById('calculate-btn');

    const monthlyEmiEl = document.getElementById('monthly-emi');
    const totalInterestEl = document.getElementById('total-interest');
    const totalPaymentEl = document.getElementById('total-payment');

    let chartInstance = null;

    // Formatting utility for Indian Rupees
    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('en-IN', {
            style: 'currency',
            currency: 'INR',
            maximumFractionDigits: 0
        }).format(amount);
    };

    const calculateEMI = () => {
        const principal = parseFloat(loanAmountInput.value);
        const annualRate = parseFloat(interestRateInput.value);
        const years = parseFloat(tenureInput.value);

        if (isNaN(principal) || isNaN(annualRate) || isNaN(years) || principal <= 0 || annualRate <= 0 || years <= 0) {
            alert('Please enter valid positive numbers for all fields.');
            return;
        }

        const monthlyRate = annualRate / 12 / 100;
        const totalMonths = years * 12;

        // EMI Formula: P x R x (1+R)^N / [(1+R)^N-1]
        const emi = (principal * monthlyRate * Math.pow(1 + monthlyRate, totalMonths)) / (Math.pow(1 + monthlyRate, totalMonths) - 1);
        
        const totalPayment = emi * totalMonths;
        const totalInterest = totalPayment - principal;

        // Update DOM
        monthlyEmiEl.textContent = formatCurrency(emi);
        totalInterestEl.textContent = formatCurrency(totalInterest);
        totalPaymentEl.textContent = formatCurrency(totalPayment);

        // Update Chart
        updateChart(principal, totalInterest);
    };

    const updateChart = (principal, interest) => {
        // Update hidden elements for testing
        document.getElementById('chart-data-principal').textContent = principal;
        document.getElementById('chart-data-interest').textContent = interest;

        const ctx = document.getElementById('breakdown-chart').getContext('2d');

        if (chartInstance) {
            chartInstance.destroy();
        }

        chartInstance = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Principal Amount', 'Total Interest'],
                datasets: [{
                    data: [principal, interest],
                    backgroundColor: [
                        '#3b82f6', // blue
                        '#f59e0b'  // amber
                    ],
                    borderColor: '#1e293b',
                    borderWidth: 2,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#f8fafc',
                            font: {
                                family: "'Inter', sans-serif"
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                let label = context.label || '';
                                if (label) {
                                    label += ': ';
                                }
                                if (context.raw !== null) {
                                    label += formatCurrency(context.raw);
                                }
                                return label;
                            }
                        }
                    }
                },
                cutout: '70%'
            }
        });
    };

    // Add event listeners
    calculateBtn.addEventListener('click', calculateEMI);

    // Initial calculation on page load
    calculateEMI();
});
