module WavefrontTest
  module List
    def test_list
      assert_gets("/api/v2/#{api_class}?offset=0&limit=100") do
        wf.list
      end

      assert_gets("/api/v2/#{api_class}?offset=10&limit=100") do
        wf.list(10)
      end
    end

    def test_list_all
      assert_gets("/api/v2/#{api_class}?limit=999&offset=0") do
        wf.list(0, :all)
      end

      assert_gets("/api/v2/#{api_class}?limit=20&offset=0") do
        wf.list(20, :all)
      end
    end
  end

  module Create
    def test_create
      [payload].flatten.each do |p|
        assert_posts("/api/v2/#{api_class}", p) { wf.create(p) }
        assert_raises(ArgumentError) { wf.create }
        assert_raises(ArgumentError) { wf.create('test') }
      end
    end
  end

  module Describe
    def test_describe
      assert_gets("/api/v2/#{api_class}/#{id}") { wf.describe(id) }
      assert_invalid_id { wf.describe(invalid_id) }
      assert_raises(ArgumentError) { wf.describe }
    end
  end

  module Delete
    def test_delete
      assert_deletes("/api/v2/#{api_class}/#{id}") { wf.delete(id) }
      assert_invalid_id { wf.delete(invalid_id) }
      assert_raises(ArgumentError) { wf.delete }
    end
  end

  module DeleteUndelete
    include Delete

    def test_undelete
      assert_posts("/api/v2/#{api_class}/#{id}/undelete") do
        wf.undelete(id)
      end

      assert_invalid_id { wf.undelete(invalid_id) }
      assert_raises(ArgumentError) { wf.undelete }
    end
  end

  module Update
    def test_update
      [payload].flatten.each do |p|
        assert_puts("/api/v2/#{api_class}/#{id}", p) do
          wf.update(id, p, false)
        end

        assert_invalid_id { wf.update(invalid_id, p) }
        assert_raises(ArgumentError) { wf.update }
      end
    end
  end

  module Clone
    def test_clone
      assert_posts("/api/v2/#{api_class}/#{id}/clone",
                   id: id, name: nil, v: nil) do
        wf.clone(id)
      end

      assert_posts("/api/v2/#{api_class}/#{id}/clone",
                   id: id, name: nil, v: 4) do
        wf.clone(id, 4)
      end

      assert_raises(ArgumentError) { wf.clone }
    end
  end

  module InstallUninstall
    def test_install
      assert_posts("/api/v2/#{api_class}/#{id}/install") { wf.install(id) }
      assert_invalid_id { wf.install(invalid_id) }
    end

    def test_uninstall
      assert_posts("/api/v2/#{api_class}/#{id}/uninstall") do
        wf.uninstall(id)
      end

      assert_invalid_id { wf.uninstall(invalid_id) }
    end
  end

  module History
    def test_describe_v
      assert_gets("/api/v2/#{api_class}/#{id}/history/4") do
        wf.describe(id, 4)
      end
    end

    def test_history
      assert_gets("/api/v2/#{api_class}/#{id}/history") { wf.history(id) }
      assert_invalid_id { wf.history(invalid_id) }
      assert_raises(ArgumentError) { wf.history }
    end
  end
end
