module WavefrontTest
  #
  # require and include this module to get tag tests
  #
  module Tag
    def test_tags
      assert_gets("/api/v2/#{api_class}/#{id}/tag") { wf.tags(id) }
      assert_invalid_id { wf.tags(invalid_id) }
    end

    def test_tag_set
      assert_posts("/api/v2/#{api_class}/#{id}/tag", '["mytag"]') do
        wf.tag_set(id, 'mytag')
      end

      assert_posts("/api/v2/#{api_class}/#{id}/tag", '["tag1","tag2"]') do
        wf.tag_set(id, %w[tag1 tag2])
      end

      assert_invalid_id { wf.tag_set(invalid_id, 'valid_tag') }

      assert_raises(Wavefront::Exception::InvalidString) do
        wf.tag_set(id, '<!!!>')
      end
    end

    def test_tag_add
      #
      # We have to use a literal 'null' to trick assert_puts into
      # checking for the right content-type
      #
      assert_puts("/api/v2/#{api_class}/#{id}/tag/mytag", 'null') do
        wf.tag_add(id, 'mytag')
      end

      assert_invalid_id { wf.tag_add(invalid_id, 'valid_tag') }

      assert_raises(Wavefront::Exception::InvalidString) do
        wf.tag_add(id, '<!!!>')
      end
    end

    def test_tag_delete
      assert_deletes("/api/v2/#{api_class}/#{id}/tag/mytag") do
        wf.tag_delete(id, 'mytag')
      end

      assert_invalid_id { wf.tag_delete(invalid_id, 'valid_tag') }

      assert_raises(Wavefront::Exception::InvalidString) do
        wf.tag_delete(id, '<!!!>')
      end
    end
  end
end
