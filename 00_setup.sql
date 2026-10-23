-- Create the project dataset in the same US multi-region as the public source.
-- Replace `your-gcp-project` before running.

CREATE SCHEMA IF NOT EXISTS `your-gcp-project.rfm_customer_segmentation`
OPTIONS (
  location = 'US',
  description = 'Reproducible RFM customer segmentation portfolio project'
);

