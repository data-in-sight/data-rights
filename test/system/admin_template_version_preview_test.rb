require "application_system_test_case"

class AdminTemplateVersionPreviewTest < ApplicationSystemTestCase

  setup do
    @sample_email = 'john@smith.com'
    @sample_password = '1234567890'
    User.create!(email: @sample_email, password_confirmation: @sample_password, password: @sample_password)
    @user = User.find_by(email: @sample_email)
    @user.confirm
  end

  teardown do
    User.find_by(email: @sample_email).destroy
  end

  test "Test preview button is there for each row" do
    Capybara.using_driver(Capybara.javascript_driver) do
      visit('/admin')
      fill_in('user_email', with: @sample_email)
      fill_in('user_password', with: @sample_password)
      click_button I18n.t('devise.sign_in', default: 'Sign in')
      has_title = page.has_content?(I18n.t('admin.actions.dashboard.title').upcase)
      take_screenshot unless has_title
      assert_equal true, has_title
      visit('/admin/template_version')
      assert_equal page.all('i', class: 'icon-eye-open').count, page.all('i', class: 'icon-info-sign').count
    end
  end

  test "Test preview button is directing you to preview page" do
    Capybara.using_driver(Capybara.javascript_driver) do
      visit('/admin')
      fill_in('user_email', with: @sample_email)
      fill_in('user_password', with: @sample_password)
      click_button I18n.t('devise.sign_in', default: 'Sign in')
      has_title = page.has_content?(I18n.t('admin.actions.dashboard.title').upcase)
      take_screenshot unless has_title
      assert_equal true, has_title
      visit('/admin/template_version')
      a = page.first('li', class: 'preview_template_member_link').find_link()
      a.click
      within_window(page.driver.browser.window_handles.last) do
        assert page.has_content?(I18n.t('admin.actions.preview_template.title').upcase)
      end
    end
  end

  test "Test preview page should have criteria selections and buttons" do
    Capybara.using_driver(Capybara.javascript_driver) do
      visit('/admin')
      fill_in('user_email', with: @sample_email)
      fill_in('user_password', with: @sample_password)
      click_button I18n.t('devise.sign_in', default: 'Sign in')
      has_title = page.has_content?(I18n.t('admin.actions.dashboard.title').upcase)
      take_screenshot unless has_title
      assert_equal true, has_title
      visit('/admin/template_version')
      a = page.first('li', class: 'preview_template_member_link').find_link()
      a.click
      within_window(page.driver.browser.window_handles.last) do
        campaign_select = page.find_by_id('campaign_id')
        assert_equal 'select', campaign_select.tag_name

        user_select = page.find_by_id('user_id')
        assert_equal 'select', user_select.tag_name

        organization_select = page.find_by_id('organization_id')
        assert_equal 'select', organization_select.tag_name

        assert page.find_button('Preview')
        assert page.find_button('PDF')
      end
    end
  end

  test "Test preview button will show the preview page" do
    Capybara.using_driver(Capybara.javascript_driver) do
      visit('/admin')
      fill_in('user_email', with: @sample_email)
      fill_in('user_password', with: @sample_password)
      click_button I18n.t('devise.sign_in', default: 'Sign in')
      has_title = page.has_content?(I18n.t('admin.actions.dashboard.title').upcase)
      take_screenshot unless has_title
      assert_equal true, has_title
      visit('/admin/template_version')
      a = page.first('li', class: 'preview_template_member_link').find_link()
      a.click
      within_window(page.driver.browser.window_handles.last) do
        preview_button = page.find_button('Preview')
        preview_button.click
        within_window(page.driver.browser.window_handles.last) do
          assert page.has_content?(I18n.t('admin.actions.preview_template.title').upcase)
        end
      end
    end
  end

  test "Test PDF button generates Pdf content" do
    Capybara.using_driver(Capybara.javascript_driver) do
      visit('/admin')
      fill_in('user_email', with: @sample_email)
      fill_in('user_password', with: @sample_password)
      click_button I18n.t('devise.sign_in', default: 'Sign in')
      has_title = page.has_content?(I18n.t('admin.actions.dashboard.title').upcase)
      take_screenshot unless has_title
      assert_equal true, has_title
      visit('/admin/template_version')
      a = page.first('li', class: 'preview_template_member_link').find_link()
      a.click
      within_window(page.driver.browser.window_handles.last) do
        preview_button = page.find_button('PDF')
        preview_button.click
        within_window(page.driver.browser.window_handles.last) do
          assert_equal 'application/pdf', page.response_headers["Content-Type"] 
        end
      end
    end
  end

end