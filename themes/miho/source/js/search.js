function initSearch() {
    var keyInput = $('#keywords'),
        back = $('#back'),
        searchContainer = $('#search-container'),
        searchResult = $('#search-result'),
        searchTpl = $('#search-tpl').html(),
        JSON_DATA = '/search.json?v=' + (+ new Date()),
        searchData;

    function loadData(success) {
        if (!searchData) {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', JSON_DATA, true);
            xhr.onload = function () {
                if (this.status >= 200 && this.status < 300) {
                    var res = JSON.parse(this.response || this.responseText);
                    searchData = res instanceof Array ? res : res.posts;
                    success(searchData);
                } else {
                    console.error(this.statusText);
                }
            };
            xhr.onerror = function () {
                console.error(this.statusText);
            };
            xhr.send();
        } else {
            success(searchData);
        }
    }

    function tpl(html, data) {
        return html.replace(/\{\w+\}/g, function (str) {
            var prop = str.replace(/\{|\}/g, '');
            return data[prop] || '';
        });
    }

    function render(data) {
        var html = '';
        if (data.length) {

            // 按照分数降序排列搜索结果, 综合得分最高的最先展示
            data.sort(function (itemA, itemB) { return itemB.value - itemA.value });

            html = data.map(function (res) {
                const post = res.item
                return tpl(searchTpl, {
                    title: post.title,
                    url: (window.mihoConfig.root + '/' + post.url)
                });
            }).join('');
        } else {
            html = '<li class="search-result-item-tips"><p>没有找到相关内容!</p></li>';
        }

        searchResult.html(html);
        containerDisplay(true);
    }
    function containerDisplay(status) {
        if (status) {
            searchContainer.addClass('search-container-show')
        } else {
            searchContainer.removeClass('search-container-show')
        }
    }

    function search(e) {
        var rawQuery = this.value.trim().toLowerCase();
        if (!rawQuery) {
            containerDisplay(false);
            return;
        }

        if (rawQuery.length < 2) {
            containerDisplay(false);
            return;
        }

        let keywords = rawQuery.split(/\s+/)



        loadData(function (items) {
            var results = [];
            items.forEach(function (item) {
                // 按照关键字出现的位置给文字设置分数
                // 出现在标题上的最先展示, 其次是分类, 再次是标签, 最次是正文
                let value = 0
                for (let keyword of keywords) {
                    if (item.title.toLowerCase().indexOf(keyword) > -1) {
                        value += 10
                    }

                    if (item.categories) {
                        for (let categorie of item.categories) {
                            if (categorie.toLowerCase().indexOf(keyword) > -1) {
                                value += 5
                            }
                        }
                    }

                    if (item.tags) {
                        for (let tag of item.tags) {
                            if (tag.toLowerCase().indexOf(keyword) > -1) {
                                value += 3
                            }
                        }
                    }

                    if (item.content.toLowerCase().indexOf(keyword) > -1) {
                        value += 1
                    }
                }

                if (value > 0) {
                    results.push({ "item": item, "value": value })
                }
            });
            render(results);
        });

        e.preventDefault();
    }

    keyInput.bind('input propertychange', search);
};
