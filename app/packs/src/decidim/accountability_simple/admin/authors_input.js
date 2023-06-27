import Tribute from "src/decidim/vendor/tribute"

((exports) => {
  const $ = exports.$; // eslint-disable-line id-length

  $(() => {
    $(".js-authors-input").each((_i, authorsEl) => {
      const $wrapper = $(authorsEl);
      const $input = $(".authors-filter", $wrapper);
      const $values = $(".values", $wrapper);
      const inputName = $wrapper.data("input-name");
      console.log(inputName);

      let $menu = $(".menu", $wrapper);
      if ($menu.length < 1) {
        $menu = $('<div class="menu"></div>');
        $input.after($menu);
      }

      const i18n = {
        remove: $wrapper.data("remove-text") || "Remove",
        loading: $wrapper.data("loading-text") || "Loading...",
        noResults: $wrapper.data("no-results-text") || "No authors available."
      };

      const createAuthor = (id, name) => {
        const $author = $(
          `<span class="author label primary" data-author-id="${id}">
            <span class="author-name">${name}</span>
            <span class="author-remove" aria-label="${i18n.remove}: ${name}"><span aria-hidden="true">&times;</span></span>
            <input type="hidden" name="${inputName}" value="${id}" data-author-name="${name}">
          </span>`
        );

        $(".author-remove", $author).on("click.authors", () => {
          $author.remove();
        });

        return $author;
      };

      const getCurrentValues = () => {
        return $("input", $values).toArray().map((el) => {
          const $authorInput = $(el);
          return { key: $authorInput.data("author-name"), value: $authorInput.val() };
        });
      };

      const filterCurrentValues = (values) => {
        const current = getCurrentValues().map((val) => val.value);
        return values.filter((val) => !current.includes(val.value));
      };

      let xhr = null;
      const tribute = new Tribute({
        autocompleteMode: true,
        // autocompleteSeparator: / \+ /, // See below, requires Tribute update
        allowSpaces: true,
        positionMenu: false,
        // replaceTextSuffix: "&nbsp;",
        menuContainer: $menu.get(0),
        menuShowMinLength: 2,
        noMatchTemplate: `<ul class="authors-no-matches"><li>${i18n.noResults}</li></ul>`,
        loadingItemTemplate: `<ul class="authors-loading"><li>${i18n.loading}</li></ul>`,
        selectTemplate: (item) => {
          if (!item || !item.original) {
            return "";
          }

          $values.append(createAuthor(item.original.value, item.original.key));
          return "";
        },
        values: (text, callback) => {
          try {
            xhr.abort();
            xhr = null;
          } catch (exception) { xhr = null; }

          xhr = $.post(
            "/api",
            {query: `{users(filter:{wildcard:"${text}"}) {id, nickname, name, __typename, ...on UserGroup{membersCount}}}`}
          ).then((response) => {
            const data = response.data.users || {};
            callback(
              filterCurrentValues(
                data.map((item) => {
                  return { key: `${item.name} (${item.nickname})`, value: item.id };
                })
              )
            );
          }).fail(() => {
            callback([]);
          });
        }
      });

      // Port https://github.com/zurb/tribute/pull/406
      // This changes the autocomplete separator from space to " + " so that
      // we can do searches such as "tag name" including a space. Otherwise
      // this would do two separate searches for "tag" and "name".
      tribute.range.getLastWordInText = (text) => {
        const final = text.replace(/\u00A0/g, " ");
        const wordsArray = final.split(/ \+ /);
        const worldsCount = wordsArray.length - 1;

        return wordsArray[worldsCount].trim();
      };

      tribute.attach($input[0]);

      // Add the initial tags to the view
      $("input", $values).each((_j, el) => {
        const $authorInput = $(el);
        $authorInput.replaceWith(createAuthor($authorInput.val(), $authorInput.data("author-name")));
      });

      $input.on("tribute-replaced", () => {
        //
      });
    });
  });
})(window);
