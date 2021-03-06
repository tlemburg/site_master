<?php 
$different_user = false;
if ($context->verify_user->id != $context->current_user->id) {
    $different_user = true;
}
?>

<form action="<?php echo $context->getEditURL(); ?>" method="POST">
    <div class="panel">
        <p>
            As a verified administrator, <?php echo $different_user?$context->verify_user->getName():'you' ?> will be able to add/remove and approve memberships, and edit site details for this site.  <strong>You do not need to verify this membership if <?php echo $different_user?$context->verify_user->getName().' does':' you do' ?> not need the admin role.</strong>
        </p>
        <p>
            <a href="<?php echo $context->site->getURL() ?>members/" class="button wdn-button">The admin role is not needed, Skip Verification</a>
        </p>
        <p>
            You have a few options to verify the admin role for this membership:
            <ul>
                <li>Upload a unique file to prove that you have physical access to the site</li>
                <li>Have verified member of this site manually verify the membership</li>
                <li>Have verified member of this site manually approve the individual roles</li>
            </ul>
        </p>
        
        <p>
            To manually verify yourself, you will need to create this file on your site:
        </p>
        <code>
            <?php echo $context->getVerificationURL(); ?>
        </code>
        <p>
            The file does not have to contain anything.  The only requirement is that the file exists.
        </p>
    </div>
    <input type="hidden" name="type" value="manual" />
    <input type="submit" value="Verify Now" />
    <a href="<?php echo $context->site->getURL() ?>members/" class="button wdn-button">Skip</a>
</form>
