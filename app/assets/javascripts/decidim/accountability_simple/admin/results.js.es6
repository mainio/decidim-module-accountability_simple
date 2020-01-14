((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;
  const { createQuillEditor } = exports.Decidim;

  const wrapperSelector = ".result-detail-items";
  const fieldSelector = ".result-detail-item";

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".result-detail-item:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".result-detail-item:not(.hidden)",
    hideOnFirstSelector: ".move-up-result-detail-item",
    hideOnLastSelector: ".move-down-result-detail-item"
  });

  const createSortableList = () => {
    createSortList(".result-detail-items-list:not(.published)", {
      handle: ".result-detail-item-divider",
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
    placeholderId: "result-detail-item-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".result-detail-items-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-result-detail-item",
    removeFieldButtonSelector: ".remove-result-detail-item",
    moveUpFieldButtonSelector: ".move-up-result-detail-item",
    moveDownFieldButtonSelector: ".move-down-result-detail-item",
    onAddField: ($field) => {
      createSortableList();

      $field.find(".editor-container").each((idx, el) => {
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

  $(fieldSelector).each((idx, el) => {
    const $target = $(el);

    hideDeletedItem($target);
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();
})(window);
