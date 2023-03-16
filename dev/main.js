function make_data_list() {
  window.location = "skp:make_data_list@";
}

function select_markers(id) {
  const useitCheckboxes = document.querySelectorAll(".useit");
  const rows = document.querySelectorAll("tr");
  rows.forEach(function (row) {
    row.style.color = "#D4D4D4";
  });

  useitCheckboxes.forEach(function (checkbox) {
    checkbox.checked = false;
  });

  id.forEach(function (i) {
    var checkbox = document.getElementById(i);
    const targetrow = document.getElementById(`row_${i}`);
    if (checkbox) {
      checkbox.checked = true;
      targetrow.style.color = "yellow";
    }
  });
}

function show_sel_dims(dims) {
  const table = document.getElementById("datatable");
  for (let i = 0; i < dims.length; i++) {
    targerRow = document.getElementById("row_" + dims[i][3]);
    if (targerRow) {
      targerRow.remove();
    }
    const row = table.insertRow(i + 1);
    row.id = "row_" + dims[i][3];
    row.style.color = "yellow";
    if (dims[i][15] == "checked") {
      var x = dims[i][1];
      var y = dims[i][0];
    } else {
      var x = dims[i][0];
      var y = dims[i][1];
    }

    row.innerHTML = `
			<td class="id"></td>
			<td class="length">${x || "0"}</td>
			<td class="allow_rotation">
				<input type="checkbox" class="rotation"${dims[i][15]}>
			</td>
			<td class="width">${y || "0"}</td>
			<td class="quantity">${1}</td>
			<td class="allow_rotation align_center">
				<input type="checkbox" class="allow_rotation"${dims[i][6]}>
			</td>
			<td class="lable">${dims[i][4]}</td>
			<td class="customer"
				contentEditable="true"
				oninput='setdata(${dims[i][3]},
				"customer",
				this.innerText)'>${dims[i][5]}
			</td>
			<td class="material"
				contentEditable="true"
				oninput='setdata(${dims[i][3]},
				"material",
				this.innerText)'
				onkeypress="return event.charCode >= 48 && event.charCode <= 57">
				${dims[i][5]}
			</td>
			<td class="top_name">
				<input type="checkbox" class="top_name"${dims[i][9]}>
			</td>
			<td class="left_name">
				<input type="checkbox" class="left_name"${dims[i][10]}>
			</td>
			<td class="bottom_name">
					<input type="checkbox" class="bottom_name"${dims[i][11]}>
			</td>
			<td class="right_name">
					<input type="checkbox" class="right_name"${dims[i][12]}>
			</td>
			<td class="top_thick_grinding"
				contentEditable="true"
				oninput='setdata(${dims[i][3]},
				"top_thick_grinding",
				this.innerText)'
				onkeypress="return event.charCode >= 48 && event.charCode <= 57">
				${dims[i][13]}
			</td>
			<td class="left_thick_grinding"
				contentEditable="true"
				oninput='setdata(${dims[i][3]},
				"left_thick_grinding",
				this.innerText)'
				onkeypress="return event.charCode >= 48 && event.charCode <= 57">
				${dims[i][14]}
			</td>
			<td class="useit">
				<input type="checkbox"
					class="useit"
					name="useit"
					id="${dims[i][3]}"
					checked>
			</td>
      <td class="remove align_center" onclick="removeRow(${dims[i][3]})">
				<img src="./close.svg" alt="remove" width="20" />
			</td>`;

    const checkboxes = row.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", (event) => {
        const checkboxClass = checkbox.className;
        const checkboxId = dims[i][3];
        const checkboxChecked = checkbox.checked;
        const targetrow = document.getElementById(`row_${checkboxId}`);
        const l = targetrow.querySelector(".length").innerHTML;
        const w = targetrow.querySelector(".width").innerHTML;

        if (checkboxClass == "rotation") {
          var lenght = targetrow.querySelector(".length");
          var width = targetrow.querySelector(".width");
          lenght.innerHTML = w;
          width.innerHTML = l;
        }

        setdata(checkboxId, checkboxClass, checkboxChecked);
      });
    });
  }
  const td = document.querySelectorAll(".id");
  for (let i = 0; i < td.length; i++) {
    td[i].innerHTML = `${i + 1}`;
  }
}

function removeRow(id) {
  const targetrow = document.getElementById(`row_${id}`);
  targetrow.remove();
  const td = document.querySelectorAll(".id");
  for (let i = 0; i < td.length; i++) {
    td[i].innerHTML = `${i + 1}`;
  }
}

function setdata(id, name, param) {
  if (name == "useit") {
    search_entity(id);
  }
  window.location = "skp:setdata@" + id + "," + name + "," + param;
}

function search_entity(id) {
  var checkbox = document.getElementById(id);
  const targetrow = document.getElementById(`row_${id}`);

  if (!checkbox.checked) {
    targetrow.style.color = "#D4D4D4";
  } else {
    targetrow.style.color = "yellow";
  }
}

function downloadXML() {
  const tableRows = document.querySelectorAll("#datatable tbody tr");
  var xmlData = '<?xml version="1.0"?><data><parts>';

  for (let i = 1; i < tableRows.length; i++) {
    const row = tableRows[i];
    const length = row.querySelector(".length").textContent;
    const width = row.querySelector(".width").textContent;
    const quantity = row.querySelector(".quantity").textContent;
    const allowRotation = row.querySelector(".allow_rotation input").checked
      ? "1"
      : "0";
    const label = row.querySelector(".lable").textContent;
    const material = row.querySelector(".material").textContent;
    const customer = row.querySelector(".customer").textContent;
    // Закатка
    const topName = row.querySelector(".top_name input").checked ? "x" : "";
    const topThick = "1";
    const leftName = row.querySelector(".left_name input").checked ? "x" : "";
    const leftThick = "1";
    const bottomName = row.querySelector(".bottom_name input").checked
      ? "x"
      : "";
    const bottomThick = "1";
    const rightName = row.querySelector(".right_name input").checked ? "x" : "";
    const rightThick = "1";
    //закатка
    const top_thick_grinding = row.querySelector(
      ".top_thick_grinding"
    ).textContent;
    const left_thick_grinding = row.querySelector(
      ".left_thick_grinding"
    ).textContent;

    const useit = row.querySelector(".useit input").checked ? "1" : "0";

    const rowData = `
			<row>
				<length>${length}</length>
				<width>${width}</width>
				<quantity>${quantity}</quantity>
				<grain>0</grain>
				<allow_rotation>${allowRotation}</allow_rotation>
				<label>${label}</label>
				<material>${material}</material>
				<customer>${customer}</customer>
				<edge_band>
					<top_name>${topName}</top_name>
					<top_thick>${topThick}</top_thick>
					<left_name>${leftName}</left_name>
					<left_thick>${leftThick}</left_thick>
					<bottom_name>${bottomName}</bottom_name>
					<bottom_thick>${bottomThick}</bottom_thick>
					<right_name>${rightName}</right_name>
					<right_thick>${rightThick}</right_thick>
				</edge_band>
				<grinding>
					<top_thick>${top_thick_grinding}</top_thick>
					<left_thick>${left_thick_grinding}</left_thick>
					<bottom_thick>0</bottom_thick>
					<right_thick>0</right_thick>
				</grinding>
				<useit>1</useit>
			</row>
		`;

    xmlData += rowData;
  }

  xmlData += "</parts></data>";

  const blob = new Blob([xmlData], { type: "application/xml" });
  const url = URL.createObjectURL(blob);

  const link = document.createElement("a");
  link.href = url;
  link.download = "data.xml";
  link.click();

  URL.revokeObjectURL(url);
}
