<?php
$metric = $context->getMetric();
$metric_plugin = $metric->getMetricObject();
$page_marks = $context->getMarks();
?>
<div class="metric-grade-details grade_<?php echo strtolower($context->letter_grade) ?>" id="metric_<?php echo $metric->id ?>">
    <header class="header">
        <div class="details">
            <span class="title"><?php echo $metric_plugin->getName(); ?></span>
            <?php
            $changes = 0;
            if (!empty($context->changes_since_last_scan)) {
                $changes = $context->changes_since_last_scan;
            }
            $message = '';
            $class = 'same-marks';
            
            if ($changes > 0) {
                $message = 'What happened?!';
                $class = 'more-marks';
            }

            if ($changes < 0) {
                $message = 'Keep it up!';
                $class = 'less-marks';
            }

            ?>
            <span class="changes <?php echo $class?>"><?php echo $changes ?> changes since the last scan.  <?php echo $message ?></span>
        </div>
        <div class="score">
            <?php
            if (!$context->isPassFail()) {
                ?>
                <span class="earned"><?php echo $context->point_grade?><span class="points_available">/<?php echo $context->points_available?></span></span>
                <?php
            }
            ?>
            <span class="weight"><?php echo $context->weight?> points of total score</span>
        </div>
        <div class="letter-grade-container">
            <span class="letter-grade unknown"><?php echo $context->letter_grade?></span>
        </div>
    </header>
    <?php 
    try {
        $description = $savvy->render($metric_plugin);
    } catch (\Savvy_TemplateException $e) {
        $description = false;
    }
    
    if ($description) {
        ?>
        <div class="metric-description">
            <?php echo $description ?>
        </div>
        <?php
    }
    ?>
    
    <div class="contents">
    <?php
    if ($page_marks->count()) {
        ?>
        <table>
            <thead>
            <tr>
                <td>
                    Reason
                </td>
                <td>
                    <?php
                    $title = 'Points Deducted';
                    if ($context->isPassFail()) {
                        $title = 'Pass/Fail';
                    }
                    echo $title;
                    ?>
                    
                </td>
                <td>
                    Options
                </td>
            </tr>
            </thead>
            <tbody>
            <?php
            foreach ($page_marks as $page_mark) {
                $mark = $page_mark->getMark();
                ?>
                <tr>
                    <td>
                        <span class="<?php echo $mark->machine_name ?>"><?php echo $mark->name; ?></span>
                    </td>
                    <td>
                        <?php
                        $points_deducted = $page_mark->points_deducted;
                        if ($context->isPassFail()) {
                            if ($page_mark->points_deducted) {
                                $points_deducted = 'Fail';
                            } else {
                                $points_deducted = 'Pass';
                            }
                        }
                        if ($page_mark->points_deducted === '0.00') {
                            if ($context->isPassFail()) {
                                $points_deducted = 'notice';
                            } else {
                                $points_deducted = '0 (notice)';
                            }
                        }
                        echo $points_deducted;
                        ?>
                    </td>
                    <td>
                        <a href="#fix-mark-<?php echo $page_mark->id ?>" class="call-modal" title="Clicking this link shows the modal">Fix</a>
                        <section class="semantic-content fix-mark-details" id="fix-mark-<?php echo $page_mark->id ?>"
                                 tabindex="-1" role="dialog" aria-labelledby="fix-mark-<?php echo $page_mark->id ?>"
                                 aria-hidden="true">

                            <div class="modal-inner">
                                <header>
                                    <h2>How to fix: <?php echo $mark->name ?></h2>
                                </header>
                                <dl>
                                    <?php
                                    if (!empty($mark->description)) {
                                        ?>
                                        <dt>Description</dt>
                                        <dd><?php echo $mark->description ?></dd>
                                    <?php
                                    }

                                    if (!empty($mark->help_text)) {
                                        ?>  
                                        <dt>Suggested Fix</dt>
                                        <dd><?php echo \Michelf\MarkdownExtra::defaultTransform($mark->help_text) ?></dd>
                                    <?php
                                    }

                                    if (!empty($page_mark->value_found)) {
                                        ?>
                                        <dt>Value Found</dt>
                                        <dd><?php echo $page_mark->value_found ?></dd>
                                    <?php
                                    }
                                    ?>
                                    <dt>Location</dt>
                                    <?php
                                    $location = 'Page';
                                    if (!empty($page_mark->line) && !empty($page_mark->line)) {
                                        $location = 'Line ' . $page_mark->line . ', Column ' . $page_mark->col;
                                    }
                                    if (!empty($page_mark->context)) {
                                        $location .= '<br />Context: <pre>' . strip_tags($page_mark->getRaw('context')) . '</pre>';
                                    }
                                    ?>
                                    <dd><?php echo $location ?></dd>
                                </dl>

                                <footer>
                                    <p>
                                        <a href="#" class="close-action button wdn-button"
                                           title="Close this modal"
                                           data-dismiss="modal">Close</a>
                                    </p>
                                </footer>
                            </div>

                            <!-- Use Hash-Bang to maintain scroll position when closing modal -->
                            <a href="#" class="modal-close close-action" title="Close this modal"
                               data-dismiss="modal" data-close="Close">&times;</a>
                        </section>
                    </td>
                </tr>
            <?php
            }
            ?>
            </tbody>
        </table>
        <?php
    } else if ($context->letter_grade == \SiteMaster\Core\Auditor\GradingHelper::GRADE_INCOMPLETE) {
        ?>
        <p>
            We were unable to scan this page.  This might be because of an error with our scanner, or it might be because of an error on the page.  Please make sure that the page passes HTML validation and there are no JavaScript errors.
        </p>
        <?php
    } else {
        ?>
        <p>Everything looks good!  Keep up the good work!</p>
        <?php
    }
    ?>
    </div>
</div>

