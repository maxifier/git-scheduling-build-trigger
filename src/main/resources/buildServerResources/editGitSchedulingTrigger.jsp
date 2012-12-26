<%@ page import="jetbrains.buildServer.buildTriggers.scheduler.CronFieldInfo" %>
<%@ page import="jetbrains.buildServer.util.Dates" %>
<%@ include file="/include.jsp" %>
<%@ taglib prefix="props" tagdir="/WEB-INF/tags/props" %>
<%@ taglib prefix="admin" tagdir="/WEB-INF/tags/admin" %>
<jsp:useBean id="propertiesBean" type="jetbrains.buildServer.controllers.BasePropertiesBean" scope="request"/>
<tr>
  <td colspan="2"><em>Build scheduler adds a build to the queue at specified time.<br/>
    The time is in the server timezone, current time: <strong><%=Dates.formatDate(Dates.now(), "dd MMM yy HH:mm Z")%></strong></em></td>
</tr>
<tr>
    <td><label for="branches">List of git branches:<l:star/></label></td>
    <td>
       <props:textProperty name="branches" style="width:100%;"/>
      <span class="smallNote">
          List of git branches (e.g master, topic2).
      </span>
    </td>
</tr>
<tr>
  <td><label for="schedulingPolicy">Trigger build:</label></td>
  <td>
    <c:set var="onchange">{
        var idx = $('schedulingPolicy').selectedIndex;
        $('weeklyPolicy').style.display = idx == 1 ? '' : 'none';
        $('cronPolicy').style.display = idx == 2 ? '' : 'none';
        $('dailyPolicy').style.display = idx == 0 || idx == 1 ? '' : 'none';
        if (idx == 2) {
          $('cronHelp').show();
        } else {
          $('cronHelp').hide();
        }
        BS.MultilineProperties.updateVisible();
    }</c:set>
    <props:selectProperty name="schedulingPolicy" onchange="${onchange}">
      <props:option value="daily">daily</props:option>
      <props:option value="weekly">weekly</props:option>
      <props:option value="cron">advanced (cron expression)</props:option>
    </props:selectProperty> <bs:help id="cronHelp" file="Configuring+Schedule+Triggers" style="${propertiesBean.properties['schedulingPolicy'] == 'cron' ? '' : 'display: none;'}"/>
  </td>
</tr>
<tr id="weeklyPolicy" style="${propertiesBean.properties['schedulingPolicy'] == 'weekly' ? '' : 'display: none;'}">
  <td>
    <label for="dayOfWeek">Day of the week:</label>
  </td>
  <td>
    <props:selectProperty name="dayOfWeek">
      <props:option value="Sunday">Sunday</props:option>
      <props:option value="Monday">Monday</props:option>
      <props:option value="Tuesday">Tuesday</props:option>
      <props:option value="Wednesday">Wednesday</props:option>
      <props:option value="Thursday">Thursday</props:option>
      <props:option value="Friday">Friday</props:option>
      <props:option value="Saturday">Saturday</props:option>
    </props:selectProperty>
  </td>
</tr>
<tr id="dailyPolicy" style="${propertiesBean.properties['schedulingPolicy'] == 'cron' ? 'display: none;' : ''}">
  <td>
    <label for="hour">Time (HH:mm):</label>
  </td>
  <td>
    <props:selectProperty name="hour">
      <c:forEach begin="0" end="23" step="1" varStatus="pos">
        <props:option value="${pos.index}"><c:if test="${pos.index < 10}">0</c:if>${pos.index}</props:option>
      </c:forEach>
    </props:selectProperty>
    <props:selectProperty name="minute">
      <c:forEach begin="0" end="59" step="5" varStatus="pos">
        <props:option value="${pos.index}"><c:if test="${pos.index < 10}">0</c:if>${pos.index}</props:option>
      </c:forEach>
    </props:selectProperty>
  </td>
</tr>
<tr id="cronPolicy" style="${propertiesBean.properties['schedulingPolicy'] == 'cron' ? '' : 'display: none;'}">
  <td colspan="2" class="noBorder" style="padding: 0;">
    <table style="width: 100%;">
    <c:set var="cronFields" value="<%=CronFieldInfo.values()%>"/>
    <c:forEach items="${cronFields}" var="field">
    <c:set var="fieldElement" value="cronExpression_${field.key}"/>
    <tr>
      <td style="width: 30%;">
        <label for="${fieldElement}"><c:out value="${field.caption}"/> <c:out value="${field.descr}"/>:</label>
      </td>
      <td>
        <props:textProperty name="${fieldElement}" maxlength="100" style="width: 8em;" className="disableBuildTypeParams"/>
        <span class="error" id="error_${fieldElement}"></span>
      </td>
    </tr>
    </c:forEach>
    </table>
    <span class="error" id="error_cronExpressionError"></span>
  </td>
</tr>
<tr>
  <td colspan="2">
    <props:checkboxProperty name="triggerBuildOnAllCompatibleAgents"/>
    <label for="triggerBuildOnAllCompatibleAgents">Trigger build on all enabled and compatible agents</label>
  </td>
</tr>
<tr>
  <td colspan="2">
    <props:checkboxProperty name="triggerBuildWithPendingChangesOnly"/>
    <label for="triggerBuildWithPendingChangesOnly">Trigger build only if there are pending changes</label>
  </td>
</tr>
<tr>
  <td colspan="2">
    <props:checkboxProperty name="enforceCleanCheckout"/>
    <label for="enforceCleanCheckout">Clean all files in checkout directory before build</label>
  </td>
</tr>
<jsp:include page="/admin/triggers/triggerRules.jsp"/>
