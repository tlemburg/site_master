<form action="<?php echo $context->getEditURL(); ?>" method="POST">
    <ul>
        <li>
            <label for="base_url">The base URL of the site</label>
            <input type="url" id="base_url" name="base_url" placeholder="http://www.yoursite.edu/" autofocus required />
        </li>
    </ul>

    <div class="panel">
        <p>
            Once the site is created, you can choose your role.  We will walk you though that process after you submit this form.
        </p>
    </div>
    
    <input type="submit" value="Add my site" />
</form>