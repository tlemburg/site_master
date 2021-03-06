<?php
ini_set('display_errors', true);

//Initialize all settings and autoloaders
require_once(__DIR__ . "/../init.php");

$production_sites = new \SiteMaster\Core\Registry\Sites\ByProductionStatus(array(
    'production_status' => \SiteMaster\Core\Registry\Site::PRODUCTION_STATUS_PRODUCTION
));
$development_sites = new \SiteMaster\Core\Registry\Sites\ByProductionStatus(array(
    'production_status' => \SiteMaster\Core\Registry\Site::PRODUCTION_STATUS_DEVELOPMENT
));

//Figure the number of sites to queue each day in order to scan them all once a month (total sites/31 days) 
$production_limit  = round($production_sites->count() / 14);  //at least Once every 14 days
$development_limit = round($development_sites->count() / 31);  //at least Once every 31 days

//Schedule production sites

$queue = new \SiteMaster\Core\Registry\Sites\AutoQueue(array(
    'queue_limit' => $production_limit,
    'production_status' => \SiteMaster\Core\Registry\Site::PRODUCTION_STATUS_PRODUCTION
));

foreach ($queue as $site) {
    $site->scheduleScan();
}

//Schedule development sites

$queue = new \SiteMaster\Core\Registry\Sites\AutoQueue(array(
    'queue_limit' => $development_limit,
    'production_status' => \SiteMaster\Core\Registry\Site::PRODUCTION_STATUS_DEVELOPMENT
));

foreach ($queue as $site) {
    $site->scheduleScan();
}
