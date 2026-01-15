defmodule IagocavalcanteWeb.PrivacyLive do
  use IagocavalcanteWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-8 sm:mt-16">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <header class="max-w-2xl">
              <h1 class="text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                Privacy Policy
              </h1>
              <p class="mt-6 text-base text-zinc-600 dark:text-zinc-400">
                Your privacy is important to us. This policy explains how we collect, use, and protect your information when you comment on our blog.
              </p>
            </header>

            <div class="mt-16 sm:mt-20">
              <div class="prose dark:prose-invert max-w-none">
                <h2>Information We Collect</h2>
                <p>When you leave a comment, we collect:</p>
                <ul>
                  <li><strong>Name:</strong> The name you provide when commenting</li>
                  <li>
                    <strong>Email address:</strong>
                    Used for moderation and to notify you of replies (not displayed publicly)
                  </li>
                  <li><strong>Comment content:</strong> Your actual comment text</li>
                  <li><strong>IP address:</strong> Automatically collected for spam prevention</li>
                  <li><strong>Browser information:</strong> User agent for security purposes</li>
                </ul>

                <h2>How We Use Your Information</h2>
                <ul>
                  <li>Display your name and comment content publicly on the blog</li>
                  <li>Moderate comments and prevent spam</li>
                  <li>Contact you about replies to your comments (if you opt-in)</li>
                  <li>Maintain the security and integrity of our website</li>
                </ul>

                <h2>Comment Moderation</h2>
                <p>All comments are moderated before publication. We reserve the right to:</p>
                <ul>
                  <li>Approve, reject, or edit comments for content and quality</li>
                  <li>Remove comments that violate our community guidelines</li>
                  <li>Block users who repeatedly post spam or inappropriate content</li>
                </ul>

                <h2>Data Retention</h2>
                <p>
                  We retain comment data indefinitely to maintain the integrity of discussions. You may request deletion of your comments by contacting us.
                </p>

                <h2>Your Rights</h2>
                <p>You have the right to:</p>
                <ul>
                  <li>Request access to your personal data</li>
                  <li>Request correction of inaccurate data</li>
                  <li>Request deletion of your comments</li>
                  <li>Withdraw consent for email notifications</li>
                </ul>

                <h2>Third Party Services</h2>
                <p>
                  We do not share your personal information with third parties except as necessary for:
                </p>
                <ul>
                  <li>Legal compliance</li>
                  <li>Spam prevention services</li>
                  <li>Website hosting and security</li>
                </ul>

                <h2>Contact Us</h2>
                <p>
                  If you have any questions about this privacy policy or want to exercise your rights, please contact us through the website contact form.
                </p>

                <p class="text-sm text-zinc-500 dark:text-zinc-400 mt-8">
                  Last updated: {Date.utc_today()}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
