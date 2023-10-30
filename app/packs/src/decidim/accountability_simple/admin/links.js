import AutoButtonsByPositionComponent from "src/decidim/admin/auto_buttons_by_position.component";
import AutoLabelByPositionComponent from "src/decidim/admin/auto_label_by_position.component";
import createDynamicFields from "src/decidim/admin/dynamic_fields.component";
import createSortList from "src/decidim/admin/sort_list.component";
import createQuillEditor from "src/decidim/editor";

(() => {
  const wrapperSelector = ".result-link-items";
  const fieldSelector = ".result-link-item";

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".result-link-item:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".result-link-item:not(.hidden)",
    hideOnFirstSelector: ".move-up-result-link-item",
    hideOnLastSelector: ".move-down-result-link-item"
  });

  const createSortableList = () => {
    createSortList(".result-link-items-list:not(.published)", {
      handle: ".result-link-item-divider",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => { autoLabelByPosition.run() }
    });
  };

  const hideDeletedItem = ($target) => {
    const inputDeleted = $target.find("input[name$=\\[deleted\\]]").val();

    if (inputDeleted === "true") {
      $target.addClass("hidden");
      $target.hide();
    }
  };

  createDynamicFields({
    placeholderId: "result-link-item-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".result-link-items-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-result-link-item",
    removeFieldButtonSelector: ".remove-result-link-item",
    moveUpFieldButtonSelector: ".move-up-result-link-item",
    moveDownFieldButtonSelector: ".move-down-result-link-item",
    onAddField: ($field) => {
      createSortableList();

      $field.find(".editor-container").each((_i, el) => {
        createQuillEditor(el);
      });

      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onRemoveField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onMoveUpField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onMoveDownField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    }
  });

  createSortableList();

  $(fieldSelector).each((_i, el) => {
    const $target = $(el);

    hideDeletedItem($target);
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();
})(window);
